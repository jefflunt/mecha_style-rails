# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::AlignedCaseWhen, :config do
  it "registers an offense and autocorrects multi-line when branches into aligned single-line then branches" do
    expect_offense(<<~RUBY)
      case adapter
      when :gcs_iam
      ^^^^^^^^^^^^^ Write `when` branches on a single line with `then`; extract complex logic into a `__method`.
        GcsIamSigner.new
      when :local
      ^^^^^^^^^^^ Write `when` branches on a single line with `then`; extract complex logic into a `__method`.
        LocalStaticSigner.new
      when :deterministic
      ^^^^^^^^^^^^^^^^^^^ Write `when` branches on a single line with `then`; extract complex logic into a `__method`.
        DeterministicSigner.new
      else
        raise ConfigurationError
      end
    RUBY

    expect_correction(<<~RUBY)
      case adapter
      when :gcs_iam       then GcsIamSigner.new
      when :local         then LocalStaticSigner.new
      when :deterministic then DeterministicSigner.new
      else
        raise ConfigurationError
      end
    RUBY
  end

  it "registers an offense and autocorrects misaligned single-line when/then branches" do
    expect_offense(<<~RUBY)
      case adapter
      when :gcs_iam then GcsIamSigner.new
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Align `then` keywords vertically across `when` branches.
      when :local then LocalStaticSigner.new
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Align `then` keywords vertically across `when` branches.
      when :deterministic then DeterministicSigner.new
      end
    RUBY

    expect_correction(<<~RUBY)
      case adapter
      when :gcs_iam       then GcsIamSigner.new
      when :local         then LocalStaticSigner.new
      when :deterministic then DeterministicSigner.new
      end
    RUBY
  end

  it "registers an offense and autocorrects an inline else branch" do
    expect_offense(<<~RUBY)
      case adapter
      when :local then LocalStaticSigner.new
      else raise ConfigurationError
      ^^^^ Place the `else` branch body on an indented new line.
      end
    RUBY

    expect_correction(<<~RUBY)
      case adapter
      when :local then LocalStaticSigner.new
      else
        raise ConfigurationError
      end
    RUBY
  end

  it "registers an offense without autocorrecting for multi-statement when branches" do
    expect_offense(<<~RUBY)
      case adapter
      when :gcs_iam
      ^^^^^^^^^^^^^ Write `when` branches on a single line with `then`; extract complex logic into a `__method`.
        log_signer
        GcsIamSigner.new
      end
    RUBY

    expect_no_corrections
  end

  context "when Layout/LineLength is configured" do
    let(:other_cops) { { "Layout/LineLength" => { "Enabled" => true, "Max" => 60 } } }

    it "registers an offense without autocorrecting when the aligned line would exceed Layout/LineLength" do
      expect_offense(<<~RUBY)
        case adapter
        when :very_long_adapter_name
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Write `when` branches on a single line with `then`; extract complex logic into a `__method`.
          VeryLongSignerClassName.new(with_extra_arguments)
        end
      RUBY

      expect_no_corrections
    end
  end

  it "does not register an offense when already formatted with aligned when/then and indented else" do
    expect_no_offenses(<<~RUBY)
      case adapter
      when :gcs_iam       then GcsIamSigner.new
      when :local         then LocalStaticSigner.new
      when :deterministic then DeterministicSigner.new
      else
        raise ConfigurationError
      end
    RUBY
  end
end
