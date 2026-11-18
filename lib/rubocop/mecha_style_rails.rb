# frozen_string_literal: true

require "pathname"
require "rubocop"
require_relative "mecha_style_rails/version"
require_relative "mecha_style_rails/plugin"

module RuboCop
  # Namespace for Jeff's custom Rails RuboCop plugin and rules.
  module MechaStyleRails
    PROJECT_ROOT = Pathname.new(__dir__).join("../..").expand_path.freeze
    CONFIG_DEFAULT = PROJECT_ROOT.join("config/default.yml").freeze
  end
end

Dir.glob(File.join(__dir__, "cop/mecha_style_rails/**/*.rb")).each do |cop_file|
  require cop_file
end
