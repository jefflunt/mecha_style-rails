# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::InlineRedirectFlash, :config do
  it "registers an offense when flash[:alert] precedes return redirect_to" do
    expect_offense(<<~RUBY, "app/controllers/auth_controller.rb")
      def google_callback
        flash[:alert] = "Invalid state."
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `alert:` directly to `redirect_to` instead of assigning `flash[:alert]` on the preceding line.
        return redirect_to root_path
      end
    RUBY
  end

  it "registers an offense when flash[:notice] precedes redirect_to" do
    expect_offense(<<~RUBY, "app/controllers/promos_controller.rb")
      def redeem
        flash[:notice] = "Applied!"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `notice:` directly to `redirect_to` instead of assigning `flash[:notice]` on the preceding line.
        redirect_to root_path
      end
    RUBY
  end

  it "does not register an offense when alert: or notice: is passed directly to redirect_to" do
    expect_no_offenses(<<~RUBY, "app/controllers/auth_controller.rb")
      def google_callback
        return redirect_to root_path, alert: "Invalid state."
      end
    RUBY
  end

  it "does not register an offense for conditional flash assignments" do
    expect_no_offenses(<<~RUBY, "app/controllers/auth_controller.rb")
      def google_callback
        flash[:notice] = "Welcome back." if welcome_back_notice
        redirect_to root_path
      end
    RUBY
  end

  it "does not register an offense when flash is not followed by redirect_to" do
    expect_no_offenses(<<~RUBY, "app/controllers/auth_controller.rb")
      def apply_promo
        flash[:notice] = "Applied!"
        true
      end
    RUBY
  end
end
