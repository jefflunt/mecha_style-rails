# frozen_string_literal: true

module RuboCop
  module Cop
    module MechaStyleRails
      # Enforces passing `alert:` or `notice:` directly to `redirect_to` instead of
      # assigning `flash[:alert]` / `flash[:notice]` immediately before `redirect_to`.
      #
      # @example
      #   # bad
      #   flash[:alert] = "Invalid state."
      #   return redirect_to root_path
      #
      #   # good
      #   return redirect_to root_path, alert: "Invalid state."
      class InlineRedirectFlash < Base
        MSG = "Pass `%<key>s:` directly to `redirect_to` instead of assigning `flash[:%<key>s]` on the preceding line."

        def_node_matcher :flash_assignment?, <<~PATTERN
          (send (send nil? :flash) :[]= (sym ${:alert :notice}) _)
        PATTERN

        def_node_matcher :redirect_call, <<~PATTERN
          {
            $(send nil? :redirect_to ...)
            (return $(send nil? :redirect_to ...))
          }
        PATTERN

        def on_begin(node)
          return unless __controller_file? && node.children.size >= 2

          node.children.each_cons(2) do |first_stmt, second_stmt|
            flash_key = flash_assignment?(first_stmt)
            redirect_node = flash_key && redirect_call(second_stmt)
            next unless redirect_node && !__has_flash_option?(redirect_node)

            add_offense(first_stmt, message: format(MSG, key: flash_key))
          end
        end
        alias on_kwbegin on_begin

        def __has_flash_option?(redirect_node)
          last_arg = redirect_node.last_argument
          return false unless last_arg&.hash_type?

          last_arg.keys.any? { |k| k.sym_type? && %i[alert notice flash].include?(k.value) }
        end

        def __controller_file?
          processed_source.file_path.tr("\\", "/").include?("app/controllers/")
        end
      end
    end
  end
end
