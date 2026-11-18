# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::NoPresenceTernary, :config do
  it "registers an offense for `params[:x].present? ? ... : ...` ternaries" do
    expect_offense(<<~RUBY, "app/controllers/api/play_histories_controller.rb")
      secs = params[:seconds_listened].present? ? params[:seconds_listened].to_i : 0
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `params[...].present?` ternary checks; use strict JSON types or direct coercion.
    RUBY
  end

  it "does not register an offense for direct coercion" do
    expect_no_offenses(<<~RUBY, "app/controllers/api/play_histories_controller.rb")
      secs = params[:seconds_listened].to_i
    RUBY
  end
end
