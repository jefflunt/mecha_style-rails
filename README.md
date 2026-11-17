# jeff-style-rails

Custom [RuboCop](https://rubocop.org) plugin enforcing personal Ruby on Rails style and conventions.

## Usage in a Rails App

Add the gem to your Rails application's `Gemfile`:

```ruby
group :development, :test do
  gem "jeff-style-rails", github: "jefflunt/jeff-style-rails", require: false
end
```

Enable the plugin in `.rubocop.yml`:

```yaml
plugins:
  - rubocop-rails
  - jeff-style-rails
```

## Adding Custom Cops

1. Create a cop class in `lib/rubocop/cop/jeff_style_rails/<cop_name>.rb` under `RuboCop::Cop::JeffStyleRails` (all files in that directory are auto-required).
2. Add its default configuration entry in `config/default.yml`.
3. Add specs in `spec/rubocop/cop/jeff_style_rails/<cop_name>_spec.rb`.

You can also place personal overrides for built-in `Style/*`, `Layout/*`, `Lint/*`, or `Rails/*` cops directly in `config/default.yml`.

## Development

```bash
bin/setup
bundle exec rake        # runs RSpec and RuboCop
bundle exec rspec       # runs cop specs only
bundle exec rubocop     # lints this repository
```
