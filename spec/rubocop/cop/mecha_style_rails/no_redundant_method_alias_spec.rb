# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::NoRedundantMethodAlias, :config do
  it "registers an offense when aliasing a bare zero-arg method like current_user" do
    expect_offense(<<~RUBY)
      def success
        user = current_user
        ^^^^^^^^^^^^^^^^^^^ Do not alias `current_user` to `user`; call `current_user` directly.
        return redirect_to root_path unless user

        @user_name = user.name
      end
    RUBY
  end

  it "does not register an offense when calling current_user directly" do
    expect_no_offenses(<<~RUBY)
      def success
        return redirect_to root_path unless current_user

        @user_name = current_user.name
      end
    RUBY
  end

  it "does not register an offense when calling a __method or _method helper" do
    expect_no_offenses(<<~RUBY)
      def on_class
        namespace = __controller_namespace
        helper = _shared_helper
        [namespace, helper]
      end
    RUBY
  end

  it "does not register an offense when the local variable is reassigned later" do
    expect_no_offenses(<<~RUBY)
      def resolve_user
        user = current_user
        user ||= __guest_user
        user
      end
    RUBY
  end

  it "does not register an offense when the RHS has a receiver or arguments" do
    expect_no_offenses(<<~RUBY)
      def handle_callback
        code = params[:code]
        state = SecureRandom.hex(24)
        [code, state]
      end
    RUBY
  end
end
