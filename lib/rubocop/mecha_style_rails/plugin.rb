# frozen_string_literal: true

require "lint_roller"

module RuboCop
  module MechaStyleRails
    # LintRoller plugin integration for RuboCop 1.72+.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: "mecha_style-rails",
          version: VERSION,
          homepage: "https://github.com/jefflunt/mecha_style-rails",
          description: "Custom RuboCop rules enforcing personal Ruby on Rails style."
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: CONFIG_DEFAULT
        )
      end
    end
  end
end
