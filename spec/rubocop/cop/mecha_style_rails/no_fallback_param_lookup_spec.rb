# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::NoFallbackParamLookup, :config do
  it "registers an offense for chained fallback param lookups" do
    expect_offense(<<~RUBY, "app/controllers/api/album_bookmarks_controller.rb")
      params[:album_id].presence || params[:album_identifier].presence || params[:id].presence
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid fallback `params` lookups; use one canonical parameter key.
    RUBY
  end

  it "registers an offense for string-to-boolean param comparisons" do
    expect_offense(<<~RUBY, "app/controllers/api/play_histories_controller.rb")
      params[:full_listen].to_s == "true"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid string-to-boolean `params` comparisons; expect strict JSON boolean types.
    RUBY
  end

  it "registers an offense for direct string boolean param comparisons" do
    expect_offense(<<~RUBY, "app/controllers/api/play_histories_controller.rb")
      params[:full_listen] == "true"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid string-to-boolean `params` comparisons; expect strict JSON boolean types.
    RUBY
  end

  it "does not register an offense for strict JSON boolean checks or single param lookups" do
    expect_no_offenses(<<~RUBY, "app/controllers/api/play_histories_controller.rb")
      is_full = params[:full_listen] == true
      album_id = params.expect(:album_id)
    RUBY
  end
end
