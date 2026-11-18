# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::NoVisibilityModifiers, :config do
  it "registers an offense for `private`" do
    expect_offense(<<~RUBY)
      class Foo
        private
        ^^^^^^^ Avoid `private`; use `_method` (protected intent) or `__method` (private intent) naming instead.

        def bar
        end
      end
    RUBY
  end

  it "registers an offense for `protected`" do
    expect_offense(<<~RUBY)
      class Foo
        protected
        ^^^^^^^^^ Avoid `protected`; use `_method` (protected intent) or `__method` (private intent) naming instead.

        def bar
        end
      end
    RUBY
  end

  it "registers an offense for `private :method_name`" do
    expect_offense(<<~RUBY)
      class Foo
        def bar
        end
        private :bar
        ^^^^^^^^^^^^ Avoid `private`; use `_method` (protected intent) or `__method` (private intent) naming instead.
      end
    RUBY
  end

  it "does not register an offense for `_method` and `__method` naming" do
    expect_no_offenses(<<~RUBY)
      class Foo
        def _protected_helper
        end

        def __private_helper
        end
      end
    RUBY
  end
end
