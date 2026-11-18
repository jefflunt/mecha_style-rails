# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Disallows inline JSON hash/map rendering in controllers.
      # Extract serialization into `app/presenters/` instead.
      #
      # Single-key `{ error: ... }` payloads are allowed by default
      # (`AllowErrorHash: true`).
      #
      # @example
      #   # bad
      #   render json: { status: "recorded", id: play.id }
      #
      #   # good
      #   render json: PlayHistoryPresenter.new(play).as_json
      class NoInlineJsonRender < Base
        MSG = "Avoid inline JSON formatting in controllers; use a presenter in `app/presenters/`."

        def_node_matcher :render_json_node, <<~PATTERN
          (send nil? :render (hash <$(pair (sym :json) $_) ...>))
        PATTERN

        def on_send(node)
          return unless __controller_file?

          render_json_node(node) do |pair_node, value_node|
            next unless __inline_formatting?(value_node)
            next if     __allow_error_hash? && __error_hash?(value_node)

            add_offense(pair_node)
          end
        end

        def __controller_file?
          processed_source.file_path.tr("\\", "/").include?("app/controllers/")
        end

        def __inline_formatting?(value_node)
          value_node.hash_type? || value_node.array_type?
        end

        def __allow_error_hash?
          cop_config.fetch("AllowErrorHash", true)
        end

        def __error_hash?(value_node)
          return false unless value_node.hash_type? && value_node.pairs.size == 1

          key = value_node.pairs.first.key
          key.sym_type? && key.value == :error
        end
      end
    end
  end
end
