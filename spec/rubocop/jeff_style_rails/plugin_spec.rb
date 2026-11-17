# frozen_string_literal: true

RSpec.describe RuboCop::JeffStyleRails::Plugin do
  subject(:plugin) { described_class.new }

  it "exposes plugin metadata" do
    about = plugin.about
    expect(about.name).to eq("jeff-style-rails")
    expect(about.version).to eq(RuboCop::JeffStyleRails::VERSION)
  end

  it "supports the rubocop engine" do
    context = Struct.new(:engine).new(:rubocop)
    expect(plugin.supported?(context)).to be(true)
  end

  it "points rules to config/default.yml" do
    context = Struct.new(:engine).new(:rubocop)
    rules = plugin.rules(context)
    expect(rules.type).to eq(:path)
    expect(rules.config_format).to eq(:rubocop)
    expect(File.exist?(rules.value)).to be(true)
  end
end
