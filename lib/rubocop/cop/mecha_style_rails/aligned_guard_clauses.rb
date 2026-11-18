# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Enforces two-column vertical alignment (both `if`/`unless` keywords and
      # conditions) and no blank lines between consecutive modifier-form guard clauses.
      #
      # @example
      #   # bad
      #   return head :unauthorized unless current_user
      #
      #   return head :forbidden if current_user.suspended?
      #
      #   # good
      #   return head :unauthorized unless current_user
      #   return head :forbidden    if     current_user.suspended?
      class AlignedGuardClauses < Base
        extend AutoCorrector
        include RangeHelp

        ALIGN_MSG = "Align consecutive guard clause keywords and conditions into two columns."
        BLANK_LINE_MSG = "Remove blank lines between consecutive guard clauses."
        GUARD_SEND_METHODS = %i[raise fail throw].freeze

        def on_begin(node)
          return if node.children.size < 2

          __guard_groups(node.children).each do |group|
            __check_blank_lines(group)
            __check_alignment(group)
          end
        end
        alias on_kwbegin on_begin

        def __guard_groups(statements)
          statements.chunk_while { |a, b| __modifier_guard?(a) && __modifier_guard?(b) }
                    .select { |group| group.size >= 2 && __modifier_guard?(group.first) }
        end

        def __modifier_guard?(node)
          return false unless node.if_type? && node.modifier_form? && node.single_line?

          __guard_body?(node.if_branch)
        end

        def __guard_body?(body)
          return false unless body
          return true  if     body.return_type? || body.next_type? || body.break_type?

          body.send_type? && body.receiver.nil? && GUARD_SEND_METHODS.include?(body.method_name)
        end

        def __check_blank_lines(group)
          group.each_cons(2) do |prev_node, curr_node|
            next if curr_node.first_line - prev_node.last_line <= 1

            gap = __gap_range(prev_node, curr_node)
            next if processed_source.contains_comment?(gap)

            add_offense(curr_node, message: BLANK_LINE_MSG) do |corrector|
              corrector.replace(gap, "\n")
            end
          end
        end

        def __gap_range(prev_node, curr_node)
          prev_end = prev_node.source_range.end_pos
          curr_start = curr_node.source_range.begin_pos - curr_node.source_range.begin.column
          range_between(prev_end, curr_start)
        end

        def __check_alignment(group)
          kw_col, cond_col = __target_columns(group)

          group.each do |node|
            next if __aligned?(node, kw_col, cond_col)

            add_offense(node, message: ALIGN_MSG) do |corrector|
              __correct_alignment(corrector, node, kw_col, cond_col)
            end
          end
        end

        def __target_columns(group)
          kw_col = group.map { |n| n.if_branch.source_range.end.column }.max + 1
          max_kw_len = group.map { |n| n.keyword.length }.max
          [kw_col, kw_col + max_kw_len + 1]
        end

        def __aligned?(node, kw_col, cond_col)
          node.loc.keyword.column == kw_col &&
            node.condition.source_range.begin.column == cond_col
        end

        def __correct_alignment(corrector, node, kw_col, cond_col)
          body_end = node.if_branch.source_range.end
          padding = "#{" " * (kw_col - body_end.column)}#{node.keyword.ljust(cond_col - kw_col)}"
          corrector.replace(range_between(body_end.end_pos, node.condition.source_range.begin_pos), padding)
        end
      end
    end
  end
end
