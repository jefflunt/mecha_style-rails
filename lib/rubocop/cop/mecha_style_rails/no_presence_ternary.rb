# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Disallows noisy `params[:x].present? ? ... : ...` ternaries in controllers.
      # Use strict JSON types or direct coercion instead.
      #
      # @example
      #   # bad
      #   params[:seconds_listened].present? ? params[:seconds_listened].to_i : 0
      #
      #   # good
      #   params[:seconds_listened].to_i
      class NoPresenceTernary < Base
        MSG = "Avoid `params[...].present?` ternary checks; use strict JSON types or direct coercion."

        def_node_matcher :presence_ternary?, <<~PATTERN
          (if (send (send (send nil? :params) :[] ...) :present?) _ _)
        PATTERN

        def on_if(node)
          return unless __controller_file?
          return unless node.ternary?
          return unless presence_ternary?(node)

          add_offense(node)
        end

        def __controller_file?
          processed_source.file_path.tr("\\", "/").include?("app/controllers/")
        end
      end
    end
  end
end
