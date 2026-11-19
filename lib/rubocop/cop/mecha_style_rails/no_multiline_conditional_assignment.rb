# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Disallows assigning variables to multi-line `if`/`unless` blocks and
      # multi-line `||=` / `&&=` expressions. Extract complex conditional logic
      # into a `__method` or use an aligned `case` statement instead.
      #
      # @example
      #   # bad
      #   bookmark = if album_or_identifier.is_a?(Album)
      #     album_bookmarks.find_by(album_id: album_or_identifier.id)
      #   else
      #     __find_bookmark_by_identifier(album_or_identifier)
      #   end
      #
      #   # good
      #   bookmark = __find_album_bookmark(album_or_identifier)
      #
      #   # good
      #   bookmark = case album_or_identifier
      #   when Album then album_bookmarks.find_by(album_id: album_or_identifier.id)
      #   else
      #     __find_bookmark_by_identifier(album_or_identifier)
      #   end
      class NoMultilineConditionalAssignment < Base
        IF_MSG = "Avoid assigning a variable to a multi-line `if`/`unless` block; extract it into a `__method` or use a `case` statement."
        OP_ASGN_MSG = "Keep `||=` / `&&=` assignments on a single line; extract multi-line logic into a `__method`."

        def on_lvasgn(node)
          return if __operator_assignment?(node)

          value = node.expression
          return unless value&.if_type? && value.multiline?

          add_offense(value, message: IF_MSG)
        end
        alias on_ivasgn on_lvasgn
        alias on_cvasgn on_lvasgn
        alias on_gvasgn on_lvasgn

        def __operator_assignment?(node)
          parent = node.parent
          parent&.or_asgn_type? || parent&.and_asgn_type?
        end

        def on_or_asgn(node)
          return unless node.multiline?

          add_offense(node, message: OP_ASGN_MSG)
        end
        alias on_and_asgn on_or_asgn
      end
    end
  end
end
