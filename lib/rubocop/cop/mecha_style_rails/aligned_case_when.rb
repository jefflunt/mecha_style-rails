# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Enforces single-line `when ... then ...` branches with vertically aligned
      # `then` keywords, and indented multi-line `else` branches in `case` statements.
      #
      # @example
      #   # bad
      #   case adapter
      #   when :gcs_iam
      #     GcsIamSigner.new
      #   when :local
      #     LocalStaticSigner.new
      #   else
      #     raise ConfigurationError
      #   end
      #
      #   # good
      #   case adapter
      #   when :gcs_iam then GcsIamSigner.new
      #   when :local   then LocalStaticSigner.new
      #   else
      #     raise ConfigurationError
      #   end
      class AlignedCaseWhen < Base
        extend AutoCorrector
        include RangeHelp

        SINGLE_LINE_MSG = "Write `when` branches on a single line with `then`; extract complex logic into a `__method`."
        ALIGN_MSG = "Align `then` keywords vertically across `when` branches."
        ELSE_MSG = "Place the `else` branch body on an indented new line."

        def on_case(node)
          when_branches = node.when_branches
          return if when_branches.empty?

          target_then_col = __target_then_column(when_branches)
          when_branches.each { |when_node| __check_when(when_node, target_then_col) }
          __check_else(node)
        end

        def __target_then_column(when_branches)
          when_branches.map { |w| w.conditions.last.source_range.end.column }.max + 1
        end

        def __check_when(when_node, target_then_col)
          body = when_node.body
          return add_offense(when_node, message: SINGLE_LINE_MSG) unless __single_line_candidate?(when_node, body)

          target_body_col = target_then_col + 5
          return if __aligned_when?(when_node, body, target_then_col, target_body_col)

          msg = when_node.single_line? && when_node.then? ? ALIGN_MSG : SINGLE_LINE_MSG
          add_offense(when_node, message: msg) do |corrector|
            next if __unsafe_autocorrect?(when_node, body, target_body_col)

            __correct_when(corrector, when_node, body, target_then_col)
          end
        end

        def __single_line_candidate?(when_node, body)
          return false unless body && !body.begin_type?

          when_node.conditions.all?(&:single_line?) && body.single_line?
        end

        def __aligned_when?(when_node, body, target_then_col, target_body_col)
          when_node.single_line? &&
            when_node.then? &&
            when_node.loc.begin.column == target_then_col &&
            body.source_range.begin.column == target_body_col
        end

        def __unsafe_autocorrect?(when_node, body, target_body_col)
          return true if processed_source.contains_comment?(when_node.source_range)

          __exceeds_line_length?(target_body_col + body.source.length)
        end

        def __exceeds_line_length?(line_length)
          line_length_config = config.for_cop("Layout/LineLength")
          return false unless line_length_config["Enabled"] != false

          max = line_length_config["Max"]
          max ? line_length > max : false
        end

        def __correct_when(corrector, when_node, body, target_then_col)
          cond_end = when_node.conditions.last.source_range.end
          range = range_between(cond_end.end_pos, body.source_range.begin_pos)
          corrector.replace(range, "#{" " * (target_then_col - cond_end.column)}then ")
        end

        def __check_else(node)
          else_branch = node.else_branch
          else_loc = node.loc.else
          return unless else_branch && else_loc
          return if     else_branch.first_line > else_loc.line

          add_offense(else_loc, message: ELSE_MSG) do |corrector|
            range = range_between(else_loc.end_pos, else_branch.source_range.begin_pos)
            corrector.replace(range, "\n#{" " * (else_loc.column + 2)}")
          end
        end
      end
    end
  end
end
