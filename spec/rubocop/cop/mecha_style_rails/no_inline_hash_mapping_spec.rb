# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::NoInlineHashMapping, :config do
  it "registers an offense for `.map { |x| { ... } }` in controllers" do
    expect_offense(<<~RUBY, "app/controllers/home_controller.rb")
      tracks.map do |t|
      ^^^^^^^^^^^^^^^^^ Avoid inline hash formatting inside controllers; extract into `app/presenters/`.
        { "id" => t.identifier, "title" => t.title }
      end
    RUBY
  end

  it "does not register an offense when mapping via a presenter" do
    expect_no_offenses(<<~RUBY, "app/controllers/home_controller.rb")
      tracks.map { |t| TrackPresenter.new(t).as_json }
    RUBY
  end

  it "does not register an offense inside presenters" do
    expect_no_offenses(<<~RUBY, "app/presenters/track_presenter.rb")
      tracks.map { |t| { "id" => t.identifier } }
    RUBY
  end
end
