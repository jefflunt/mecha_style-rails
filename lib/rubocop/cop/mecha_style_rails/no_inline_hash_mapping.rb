# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Disallows inline `.map { |x| { ... } }` hash formatting in controllers.
      # Extract serialization into `app/presenters/` (or model formatting methods).
      #
      # @example
      #   # bad
      #   tracks.map { |t| { "id" => t.identifier, "title" => t.title } }
      #
      #   # good
      #   tracks.map { |t| TrackPresenter.new(t).as_json }
      class NoInlineHashMapping < Base
        MSG = "Avoid inline hash formatting inside controllers; extract into `app/presenters/`."

        def_node_matcher :inline_hash_map?, <<~PATTERN
          (block (send _ {:map :collect}) _ (hash ...))
        PATTERN

        def on_block(node)
          return unless __controller_file?
          return unless inline_hash_map?(node)

          add_offense(node)
        end

        def __controller_file?
          processed_source.file_path.tr("\\", "/").include?("app/controllers/")
        end
      end
    end
  end
end
