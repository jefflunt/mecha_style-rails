# mecha_style-rails Architecture & Conventions

## Overview
`mecha_style-rails` is a custom RuboCop plugin gem (`LintRoller::Plugin`) for enforcing personal Ruby on Rails style and conventions.

## Key Decisions
- **Plugin System**: Uses RuboCop 1.72+ `lint_roller` plugin API (`RuboCop::MechaStyleRails::Plugin`) declared via `default_lint_roller_plugin` in `mecha_style-rails.gemspec`.
- **Auto-Loading Cops**: `lib/rubocop/mecha_style_rails.rb` requires all files matching `lib/rubocop/cop/mecha_style_rails/**/*.rb`.
- **Default Configuration**: `config/default.yml` holds default settings for custom `MechaStyleRails/*` cops as well as personal overrides (`Layout/LineLength` `Max: 256`, `Style/GuardClause` `MinBodyLength: 1`, `Rails/DefaultScope`).
- **Visibility Naming Convention**: `private` and `protected` keywords are disallowed (`MechaStyleRails/NoVisibilityModifiers`); use `_method` for protected intent and `__method` for private intent so all methods remain directly unit-testable.
- **Controller & Serialization Conventions**:
  - Namespaced controllers (`Api::*`, `Admin::*`, etc.) must inherit from `<Namespace>::BaseController` (`MechaStyleRails/NamespaceBaseController`).
  - Inline JSON hash/array rendering and inline `.map { |x| { ... } }` formatting in controllers are disallowed (`MechaStyleRails/NoInlineJsonRender`, `MechaStyleRails/NoInlineHashMapping`); extract serialization into `app/presenters/`.
  - Fallback `params` chains, string-to-boolean param checks, and noisy `params[:x].present? ? ... : ...` ternaries are disallowed (`MechaStyleRails/NoFallbackParamLookup`, `MechaStyleRails/NoPresenceTernary`); expect strict JSON types.
  - Assigning `flash[:alert]` / `flash[:notice]` immediately before `redirect_to` is disallowed (`MechaStyleRails/InlineRedirectFlash`); pass `alert:` / `notice:` directly to `redirect_to`.
- **Testing & Linting**: Uses RSpec with `rubocop/rspec/support` (`expect_offense`, `expect_no_offenses`, `expect_correction`) and `RuboCop::ConfigLoader.inject_defaults!`. Run `bundle exec rake` to execute both RSpec and RuboCop.
- **Ruby Environment**: Targets Ruby `>= 3.2.0` (developed on Ruby `4.0.9` with rbenv gemset `mecha_style-rails`).
