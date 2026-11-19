# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::InlineFallbackReturn, :config do
  it "registers an offense and autocorrects var = a; var ||= b; var into a || b" do
    expect_offense(<<~RUBY)
      def resolve_user
        user = current_user
        ^^^^^^^^^^^^^^^^^^^ Return `current_user || __guest_user` directly instead of assigning and returning `user`.
        user ||= __guest_user
        user
      end
    RUBY

    expect_correction(<<~RUBY)
      def resolve_user
        current_user || __guest_user
      end
    RUBY
  end

  it "registers an offense and autocorrects var = a; var &&= b; var into a && b" do
    expect_offense(<<~RUBY)
      def resolve_token
        token = raw_token
        ^^^^^^^^^^^^^^^^^ Return `raw_token && __normalize(raw_token)` directly instead of assigning and returning `token`.
        token &&= __normalize(raw_token)
        token
      end
    RUBY

    expect_correction(<<~RUBY)
      def resolve_token
        raw_token && __normalize(raw_token)
      end
    RUBY
  end

  it "moves comments inside the 3-line range above the collapsed expression" do
    expect_offense(<<~RUBY)
      def resolve_user
        user = current_user
        ^^^^^^^^^^^^^^^^^^^ Return `current_user || __guest_user` directly instead of assigning and returning `user`.
        # Fallback to guest
        user ||= __guest_user
        user
      end
    RUBY

    expect_correction(<<~RUBY)
      def resolve_user
        # Fallback to guest
        current_user || __guest_user
      end
    RUBY
  end

  it "does not register an offense when the fallback expression references the variable" do
    expect_no_offenses(<<~RUBY)
      def resolve_token
        token = raw_token
        token &&= __normalize(token)
        token
      end
    RUBY
  end

  it "does not register an offense when already written directly" do
    expect_no_offenses(<<~RUBY)
      def resolve_user
        current_user || __guest_user
      end
    RUBY
  end
end
