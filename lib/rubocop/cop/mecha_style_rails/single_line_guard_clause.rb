# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Enforces single-line modifier form for single-statement guard clauses
      # (`return`, `next`, `break`, `raise`, `fail`, `throw`) when the resulting
      # line fits within `Layout/LineLength`.
      #
      # @example
      #   # bad
      #   unless valid_state?
      #     return redirect_to root_path, alert: "Invalid state."
      #   end
      #
      #   # good
      #   return redirect_to root_path, alert: "Invalid state." unless valid_state?
      class SingleLineGuardClause < Base
        extend AutoCorrector

        MSG = "Write single-statement guard clauses on a single line."
        GUARD_SEND_METHODS = %i[raise fail throw].freeze

        def on_if(node)
          return unless __single_line_guard_candidate?(node)

          replacement = __single_line_source(node)

          add_offense(node) do |corrector|
            next if __unsafe_autocorrect?(node, replacement)

            corrector.replace(node, replacement)
          end
        end

        def __single_line_guard_candidate?(node)
          return false unless __block_if?(node)

          body = node.if_branch
          return false unless body && __guard_statement?(body)
          return false unless node.condition.single_line? && body.single_line?

          !__assigns_local_variable?(node.condition)
        end

        def __block_if?(node)
          !(node.ternary? || node.modifier_form? || node.elsif? || node.else?)
        end

        def __single_line_source(node)
          "#{node.if_branch.source} #{node.keyword} #{node.condition.source}"
        end

        def __guard_statement?(node)
          return true if node.return_type? || node.next_type? || node.break_type?

          node.send_type? && node.receiver.nil? && GUARD_SEND_METHODS.include?(node.method_name)
        end

        def __assigns_local_variable?(condition)
          condition.lvasgn_type? || condition.each_descendant(:lvasgn).any?
        end

        def __exceeds_line_length?(node, replacement)
          max = __max_line_length
          return false unless max

          node.loc.keyword.column + replacement.length > max
        end

        def __max_line_length
          line_length_config = config.for_cop("Layout/LineLength")
          return nil unless line_length_config["Enabled"] != false

          line_length_config["Max"]
        end

        def __unsafe_autocorrect?(node, replacement)
          return true if processed_source.contains_comment?(node.source_range)
          return true if __exceeds_line_length?(node, replacement)

          [node.if_branch, node.condition].any? do |part|
            __contains_keyword_logic?(part) || __contains_do_end_block?(part)
          end
        end

        def __contains_keyword_logic?(node)
          nodes = [node, *node.descendants]
          nodes.any? { |n| (n.and_type? || n.or_type?) && n.keyword? }
        end

        def __contains_do_end_block?(node)
          nodes = [node, *node.descendants]
          nodes.any? { |n| n.block_type? && n.keywords? }
        end
      end
    end
  end
end
