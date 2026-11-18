# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Starter template cop showing AST node pattern matching and autocorrection.
      # Disabled by default in `config/default.yml`.
      #
      # @example
      #   # bad
      #   legacy_helper(user)
      #
      #   # good
      #   modern_helper(user)
      class Example < Base
        extend AutoCorrector

        MSG = "Prefer `modern_helper` over `legacy_helper`."
        RESTRICT_ON_SEND = %i[legacy_helper].freeze

        def_node_matcher :legacy_helper_call?, <<~PATTERN
          (send nil? :legacy_helper ...)
        PATTERN

        def on_send(node)
          return unless legacy_helper_call?(node)

          add_offense(node.loc.selector) do |corrector|
            corrector.replace(node.loc.selector, "modern_helper")
          end
        end
      end
    end
  end
end
