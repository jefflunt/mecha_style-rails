# jeff-style-rails Architecture & Conventions

## Overview
`jeff-style-rails` is a custom RuboCop plugin gem (`LintRoller::Plugin`) for enforcing personal Ruby on Rails style and conventions.

## Key Decisions
- **Plugin System**: Uses RuboCop 1.72+ `lint_roller` plugin API (`RuboCop::JeffStyleRails::Plugin`) declared via `default_lint_roller_plugin` in `jeff-style-rails.gemspec`.
- **Auto-Loading Cops**: `lib/rubocop/jeff_style_rails.rb` requires all files matching `lib/rubocop/cop/jeff_style_rails/**/*.rb`.
- **Default Configuration**: `config/default.yml` holds default settings for custom `JeffStyleRails/*` cops as well as personal overrides for built-in RuboCop and `rubocop-rails` cops.
- **Testing & Linting**: Uses RSpec with `rubocop/rspec/support` (`expect_offense`, `expect_no_offenses`, `expect_correction`) and `RuboCop::ConfigLoader.inject_defaults!`. Run `bundle exec rake` to execute both RSpec and RuboCop.
- **Ruby Environment**: Targets Ruby `>= 3.2.0` (developed on Ruby `4.0.9` with rbenv gemset `jeff-style-rails`).
