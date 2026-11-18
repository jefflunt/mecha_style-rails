# frozen_string_literal: true

require_relative "lib/rubocop/mecha_style_rails/version"

Gem::Specification.new do |spec|
  spec.name = "mecha_style-rails"
  spec.version = RuboCop::MechaStyleRails::VERSION
  spec.authors = ["Jeff Lunt"]

  spec.summary = "Custom RuboCop rules enforcing personal Ruby on Rails style."
  spec.description = "A RuboCop plugin containing custom cops and configuration for Jeff's Ruby on Rails conventions."
  spec.homepage = "https://github.com/jefflunt/mecha_style-rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["default_lint_roller_plugin"] = "RuboCop::MechaStyleRails::Plugin"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    Dir["config/**/*", "lib/**/*", "LICENSE.txt", "README.md"]
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "lint_roller", "~> 1.1"
  spec.add_dependency "rubocop", "~> 1.72"
  spec.add_dependency "rubocop-rails", "~> 2.28"
end
