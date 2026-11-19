# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Enforces that only namespaced `BaseController` classes (e.g.
      # `Public::BaseController`, `Api::BaseController`, `Api::V1::BaseController`)
      # may inherit from `ApplicationController`. Top-level controllers cannot
      # inherit from `ApplicationController`, and other namespaced controllers must
      # inherit from their namespace's `BaseController`.
      #
      # @example
      #   # bad (in app/controllers/auth_controller.rb)
      #   class AuthController < ApplicationController
      #   end
      #
      #   # bad (in app/controllers/api/play_histories_controller.rb)
      #   module Api
      #     class PlayHistoriesController < ApplicationController
      #     end
      #   end
      #
      #   # good (in app/controllers/public/base_controller.rb)
      #   module Public
      #     class BaseController < ApplicationController
      #     end
      #   end
      #
      #   # good (in app/controllers/api/play_histories_controller.rb)
      #   module Api
      #     class PlayHistoriesController < Api::BaseController
      #     end
      #   end
      class NamespaceBaseController < Base
        MSG = "Namespaced controllers must inherit from `%<expected>s` (or `BaseController`), not `%<actual>s`."
        TOP_LEVEL_MSG = "Only namespaced `BaseController` classes may inherit from `ApplicationController`; move this controller into a namespace."

        def on_class(node)
          segments = __controller_namespace_segments
          return unless segments

          parent = node.parent_class
          return unless parent

          if segments.empty?
            __check_top_level_controller(parent)
          else
            __check_namespaced_controller(node, parent, segments)
          end
        end

        def __check_top_level_controller(parent)
          return unless ["ApplicationController", "::ApplicationController"].include?(parent.source)

          add_offense(parent, message: TOP_LEVEL_MSG)
        end

        def __check_namespaced_controller(node, parent, segments)
          return if node.identifier.short_name == :BaseController

          expected = "#{segments.join("::")}::BaseController"
          return if [expected, "BaseController"].include?(parent.source)

          add_offense(parent, message: format(MSG, expected: expected, actual: parent.source))
        end

        def __controller_namespace_segments
          path = processed_source.file_path.tr("\\", "/")
          match = path.match(%r{(?:^|/)app/controllers/(.+/)?[^/]+_controller\.rb\z})
          return    unless match
          return [] unless match[1]

          match[1].split("/").map { |segment| __camelize(segment) }
        end

        def __camelize(segment)
          segment.split("_").map(&:capitalize).join
        end
      end
    end
  end
end
