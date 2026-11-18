# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::AlignedGuardClauses, :config do
  it "registers an offense and autocorrects misaligned consecutive guard clauses with if and unless" do
    expect_offense(<<~RUBY)
      def validate_request
        return head :unauthorized unless current_user
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Align consecutive guard clause keywords and conditions into two columns.
        return head :forbidden if current_user.suspended?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Align consecutive guard clause keywords and conditions into two columns.
        return render_error("Missing ID") if params[:id].blank?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Align consecutive guard clause keywords and conditions into two columns.
      end
    RUBY

    expect_correction(<<~RUBY)
      def validate_request
        return head :unauthorized         unless current_user
        return head :forbidden            if     current_user.suspended?
        return render_error("Missing ID") if     params[:id].blank?
      end
    RUBY
  end

  it "registers an offense and removes blank lines between consecutive guard clauses" do
    expect_offense(<<~RUBY)
      def validate_request
        return head :unauthorized unless current_user

        return head :forbidden    if     current_user.suspended?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove blank lines between consecutive guard clauses.
      end
    RUBY

    expect_correction(<<~RUBY)
      def validate_request
        return head :unauthorized unless current_user
        return head :forbidden    if     current_user.suspended?
      end
    RUBY
  end

  it "does not register an offense when consecutive guard clauses are already aligned" do
    expect_no_offenses(<<~RUBY)
      def validate_request
        return head :unauthorized         unless current_user
        return head :forbidden            if     current_user.suspended?
        return render_error("Missing ID") if     params[:id].blank?
      end
    RUBY
  end

  it "does not register an offense when all clauses in a group use if and are aligned" do
    expect_no_offenses(<<~RUBY)
      def validate_request
        return head :forbidden            if current_user.suspended?
        return render_error("Missing ID") if params[:id].blank?
      end
    RUBY
  end

  it "does not align across intervening business logic" do
    expect_no_offenses(<<~RUBY)
      def google_callback
        return redirect_to root_path, alert: "Invalid state." unless __valid_oauth_state?

        code = params[:code]
        return redirect_to root_path, alert: "Missing code." if code.blank?
      end
    RUBY
  end

  it "does not register an offense for a single guard clause" do
    expect_no_offenses(<<~RUBY)
      def validate_request
        return head :unauthorized unless current_user
      end
    RUBY
  end
end
