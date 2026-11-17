# frozen_string_literal: true

RSpec.describe RuboCop::Cop::JeffStyleRails::Example, :config do
  it "registers an offense and autocorrects `legacy_helper`" do
    expect_offense(<<~RUBY)
      legacy_helper(user)
      ^^^^^^^^^^^^^ Prefer `modern_helper` over `legacy_helper`.
    RUBY

    expect_correction(<<~RUBY)
      modern_helper(user)
    RUBY
  end

  it "does not register an offense for `modern_helper`" do
    expect_no_offenses(<<~RUBY)
      modern_helper(user)
    RUBY
  end
end
