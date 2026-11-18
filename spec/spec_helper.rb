# frozen_string_literal: true

require "mecha_style-rails"
require "rubocop/rspec/support"

RuboCop::ConfigLoader.inject_defaults!(RuboCop::MechaStyleRails::CONFIG_DEFAULT.to_s)

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.raise_on_warning = true
  config.fail_if_no_examples = true
  config.order = :random
  Kernel.srand config.seed
end
