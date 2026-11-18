# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::SingleLineGuardClause, :config do
  it "registers an offense and autocorrects a 3-line unless return guard clause" do
    expect_offense(<<~RUBY)
      def google_callback
        unless __valid_oauth_state?(session.delete(:oauth_state))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Write single-statement guard clauses on a single line.
          return redirect_to root_path, alert: "Authentication session expired or invalid state. Please try again."
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def google_callback
        return redirect_to root_path, alert: "Authentication session expired or invalid state. Please try again." unless __valid_oauth_state?(session.delete(:oauth_state))
      end
    RUBY
  end

  it "registers an offense for if/next/break/raise guard clauses" do
    expect_offense(<<~RUBY)
      items.each do |item|
        if item.nil?
        ^^^^^^^^^^^^ Write single-statement guard clauses on a single line.
          next
        end
        if item.invalid?
        ^^^^^^^^^^^^^^^^ Write single-statement guard clauses on a single line.
          raise ArgumentError, "invalid"
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      items.each do |item|
        next if item.nil?
        raise ArgumentError, "invalid" if item.invalid?
      end
    RUBY
  end

  it "does not register an offense when the guard clause is already a single line" do
    expect_no_offenses(<<~RUBY)
      def google_callback
        return redirect_to root_path, alert: "Invalid state." unless __valid_oauth_state?
      end
    RUBY
  end

  it "does not register an offense when there is an else branch" do
    expect_no_offenses(<<~RUBY)
      def google_callback
        if valid?
          return :ok
        else
          render :error
        end
      end
    RUBY
  end

  it "does not register an offense for multi-statement guard blocks" do
    expect_no_offenses(<<~RUBY)
      def google_callback
        unless valid?
          log_failure
          return head :unauthorized
        end
      end
    RUBY
  end

  it "does not register an offense for non-guard if blocks" do
    expect_no_offenses(<<~RUBY)
      def google_callback
        if params[:ref].present?
          session[:referral_code] = params[:ref]
        end
      end
    RUBY
  end

  context "when Layout/LineLength is configured" do
    let(:other_cops) { { "Layout/LineLength" => { "Enabled" => true, "Max" => 120 } } }

    it "registers an offense but does not autocorrect when the single-line form would exceed Layout/LineLength" do
      long_message = "x" * 100
      expect_offense(<<~RUBY)
        def google_callback
          unless valid?
          ^^^^^^^^^^^^^ Write single-statement guard clauses on a single line.
            return redirect_to root_path, alert: "#{long_message}"
          end
        end
      RUBY

      expect_no_corrections
    end
  end

  it "does not register an offense when the condition assigns a local variable" do
    expect_no_offenses(<<~RUBY)
      def google_callback
        if (user = User.find_by(id: params[:id]))
          return user
        end
      end
    RUBY
  end

  it "registers an offense but does not autocorrect when the block contains a comment" do
    expect_offense(<<~RUBY)
      def google_callback
        unless valid?
        ^^^^^^^^^^^^^ Write single-statement guard clauses on a single line.
          # Keep session clean
          return head :unauthorized
        end
      end
    RUBY

    expect_no_corrections
  end
end
