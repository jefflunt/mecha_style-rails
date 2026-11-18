# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Disallows `private` and `protected` visibility modifiers.
      #
      # Instead of hiding methods behind visibility modifiers (which makes unit
      # testing harder), communicate intent by naming convention:
      # - `_method_name` for protected-intent methods
      # - `__method_name` for private-intent methods
      #
      # @example
      #   # bad
      #   class Foo
      #     private
      #
      #     def helper
      #     end
      #   end
      #
      #   # good
      #   class Foo
      #     def __helper
      #     end
      #   end
      class NoVisibilityModifiers < Base
        MSG = "Avoid `%<modifier>s`; use `_method` (protected intent) or `__method` (private intent) naming instead."

        def_node_matcher :visibility_modifier?, <<~PATTERN
          (send nil? ${:private :protected} ...)
        PATTERN

        def on_send(node)
          visibility_modifier?(node) do |modifier|
            add_offense(node, message: format(MSG, modifier: modifier))
          end
        end
      end
    end
  end
end
