# frozen_string_literal: true

require "pathname"
require "rubocop"
require_relative "jeff_style_rails/version"
require_relative "jeff_style_rails/plugin"

module RuboCop
  # Namespace for Jeff's custom Rails RuboCop plugin and rules.
  module JeffStyleRails
    PROJECT_ROOT = Pathname.new(__dir__).join("../..").expand_path.freeze
    CONFIG_DEFAULT = PROJECT_ROOT.join("config/default.yml").freeze
  end
end

Dir.glob(File.join(__dir__, "cop/jeff_style_rails/**/*.rb")).each do |cop_file|
  require cop_file
end
