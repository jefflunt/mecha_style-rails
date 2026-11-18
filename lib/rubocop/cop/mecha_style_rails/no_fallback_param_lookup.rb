# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Disallows fallback param key lookups and string-to-boolean param checks.
      # Use a single canonical param key and strict JSON types instead.
      #
      # @example
      #   # bad
      #   params[:album_id].presence || params[:id].presence
      #
      #   # bad
      #   params[:full_listen].to_s == "true"
      #
      #   # good
      #   params.expect(:album_id)
      #   params[:full_listen] == true
      class NoFallbackParamLookup < Base
        MSG_FALLBACK = "Avoid fallback `params` lookups; use one canonical parameter key."
        MSG_STRING_BOOL = "Avoid string-to-boolean `params` comparisons; expect strict JSON boolean types."

        def_node_matcher :param_access?, <<~PATTERN
          (send (send nil? :params) :[] ...)
        PATTERN

        def_node_matcher :string_bool_comparison?, <<~PATTERN
          {
            (send (send (send (send nil? :params) :[] ...) :to_s) :== (str {"true" "false"}))
            (send (send (send nil? :params) :[] ...) :== (str {"true" "false"}))
          }
        PATTERN

        def on_or(node)
          return unless __controller_file?
          return if     node.parent&.or_type?
          return unless __contains_param_access?(node.lhs) && __contains_param_access?(node.rhs)

          add_offense(node, message: MSG_FALLBACK)
        end

        def on_send(node)
          return unless __controller_file?
          return unless string_bool_comparison?(node)

          add_offense(node, message: MSG_STRING_BOOL)
        end

        def __controller_file?
          processed_source.file_path.tr("\\", "/").include?("app/controllers/")
        end

        def __contains_param_access?(node)
          return true if param_access?(node)

          node.each_descendant(:send).any? { |send_node| param_access?(send_node) }
        end
      end
    end
  end
end
