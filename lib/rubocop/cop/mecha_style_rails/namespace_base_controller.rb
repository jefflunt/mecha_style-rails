# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Enforces that namespaced controllers inherit from their namespace's
      # `BaseController` (e.g. `Api::BaseController`, `Admin::BaseController`)
      # instead of `ApplicationController`.
      #
      # @example
      #   # bad (in app/controllers/api/play_histories_controller.rb)
      #   module Api
      #     class PlayHistoriesController < ApplicationController
      #     end
      #   end
      #
      #   # good
      #   module Api
      #     class PlayHistoriesController < Api::BaseController
      #     end
      #   end
      #
      #   # good
      #   module Api
      #     class PlayHistoriesController < BaseController
      #     end
      #   end
      class NamespaceBaseController < Base
        MSG = "Namespaced controllers must inherit from `%<expected>s` (or `BaseController`), not `%<actual>s`."

        def on_class(node)
          namespace = __controller_namespace
          return unless namespace
          return if node.identifier.short_name == :BaseController

          parent = node.parent_class
          return unless parent

          expected = "#{namespace}::BaseController"
          return if __valid_parent?(parent, expected)

          add_offense(parent, message: format(MSG, expected: expected, actual: parent.source))
        end

        def __controller_namespace
          path = processed_source.file_path.tr("\\", "/")
          match = path.match(%r{(?:^|/)app/controllers/([^/]+)/[^/]+_controller\.rb\z})
          return unless match

          __camelize(match[1])
        end

        def __valid_parent?(parent, expected)
          [expected, "BaseController"].include?(parent.source)
        end

        def __camelize(segment)
          segment.split("_").map(&:capitalize).join
        end
      end
    end
  end
end
