# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Disallows aliasing a bare zero-argument method call to a local variable
      # when the variable is not reassigned (e.g. `user = current_user`).
      # Private/protected helper calls (`__method`, `_method`) are excluded.
      #
      # @example
      #   # bad
      #   def success
      #     user = current_user
      #     return redirect_to root_path unless user
      #
      #     @user_name = user.name
      #   end
      #
      #   # good
      #   def success
      #     return redirect_to root_path unless current_user
      #
      #     @user_name = current_user.name
      #   end
      class NoRedundantMethodAlias < Base
        MSG = "Do not alias `%<method>s` to `%<var>s`; call `%<method>s` directly."

        def on_lvasgn(node)
          return if __operator_assignment?(node)

          value = node.expression
          return unless __bare_public_method_call?(value)
          return if     __reassigned_in_scope?(node)

          add_offense(node, message: format(MSG, method: value.method_name, var: node.name))
        end

        def __operator_assignment?(node)
          parent = node.parent
          parent&.or_asgn_type? || parent&.and_asgn_type?
        end

        def __bare_public_method_call?(node)
          return false unless node&.send_type?
          return false unless node.receiver.nil? && node.arguments.empty?

          !node.method_name.to_s.start_with?("_")
        end

        def __reassigned_in_scope?(lvasgn_node)
          scope = lvasgn_node.each_ancestor(:def, :defs, :block, :numblock, :class, :module).first
          return false unless scope

          scope.each_descendant(:lvasgn).any? do |other|
            other != lvasgn_node && other.name == lvasgn_node.name
          end
        end
      end
    end
  end
end
