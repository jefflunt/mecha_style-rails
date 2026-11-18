# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::NoInlineJsonRender, :config do
  it "registers an offense for inline JSON hash rendering in controllers" do
    expect_offense(<<~RUBY, "app/controllers/api/play_histories_controller.rb")
      render json: { status: "recorded", id: play.id }
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid inline JSON formatting in controllers; use a presenter in `app/presenters/`.
    RUBY
  end

  it "allows single-key error hashes by default" do
    expect_no_offenses(<<~RUBY, "app/controllers/api/play_histories_controller.rb")
      render json: { error: "Play history not found" }, status: :not_found
    RUBY
  end

  it "does not register an offense when rendering a presenter" do
    expect_no_offenses(<<~RUBY, "app/controllers/api/play_histories_controller.rb")
      render json: PlayHistoryPresenter.new(play).as_json
    RUBY
  end

  it "does not register an offense outside controllers" do
    expect_no_offenses(<<~RUBY, "app/presenters/play_history_presenter.rb")
      render json: { status: "recorded", id: play.id }
    RUBY
  end
end
