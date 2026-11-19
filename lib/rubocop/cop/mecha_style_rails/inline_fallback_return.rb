# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Collapses `var = a; var ||= b; var` (or `&&=`) at the end of a method or
      # block into `a || b` (or `a && b`), eliminating the temporary variable.
      #
      # @example
      #   # bad
      #   def resolve_user
      #     user = current_user
      #     user ||= __guest_user
      #     user
      #   end
      #
      #   # good
      #   def resolve_user
      #     current_user || __guest_user
      #   end
      class InlineFallbackReturn < Base
        extend AutoCorrector
        include RangeHelp

        MSG = "Return `%<expr>s` directly instead of assigning and returning `%<var>s`."

        def on_def(node)
          body = node.body
          return unless body&.begin_type? && body.children.size >= 3

          stmt1, stmt2, stmt3 = body.children.last(3)
          return unless __collapsible_tail?(stmt1, stmt2, stmt3)

          __register_fallback_offense(stmt1, stmt2, stmt3)
        end
        alias on_defs on_def
        alias on_block on_def

        def __register_fallback_offense(stmt1, stmt2, stmt3)
          replacement = __replacement_source(stmt1, stmt2, stmt3)
          add_offense(stmt1, message: format(MSG, expr: replacement, var: stmt1.name)) do |corrector|
            range = range_between(stmt1.source_range.begin_pos, stmt3.source_range.end_pos)
            corrector.replace(range, "#{__preserved_comments(range, stmt1)}#{replacement}")
          end
        end

        def __preserved_comments(range, stmt1)
          indent = " " * stmt1.source_range.begin.column
          processed_source.comments
                          .select { |comment| range.overlaps?(comment.source_range) }
                          .map { |comment| "#{comment.text}\n#{indent}" }
                          .join
        end

        def __collapsible_tail?(stmt1, stmt2, stmt3)
          return false unless stmt1.lvasgn_type? && stmt1.expression
          return false unless __matching_op_asgn?(stmt2, stmt1.name)
          return false unless __returns_var?(stmt3, stmt1.name)

          !__references_var?(stmt2.expression, stmt1.name)
        end

        def __matching_op_asgn?(stmt, var_name)
          return false unless stmt.or_asgn_type? || stmt.and_asgn_type?

          target = stmt.node_parts.first
          target&.lvasgn_type? && target.name == var_name
        end

        def __returns_var?(stmt, var_name)
          lvar = stmt.return_type? ? stmt.first_argument : stmt
          lvar&.lvar_type? && lvar.name == var_name
        end

        def __references_var?(node, var_name)
          [node, *node.descendants].any? { |n| n.lvar_type? && n.name == var_name }
        end

        def __replacement_source(stmt1, stmt2, stmt3)
          op = stmt2.or_asgn_type? ? "||" : "&&"
          prefix = stmt3.return_type? ? "return " : ""
          "#{prefix}#{stmt1.expression.source} #{op} #{stmt2.expression.source}"
        end
      end
    end
  end
end
