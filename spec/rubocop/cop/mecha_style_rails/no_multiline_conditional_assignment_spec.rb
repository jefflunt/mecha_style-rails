# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::NoMultilineConditionalAssignment, :config do
  it "registers an offense for assigning a local variable to a multi-line if/else block" do
    expect_offense(<<~RUBY)
      def unbookmark_album!(album_or_identifier)
        bookmark = if album_or_identifier.is_a?(Album)
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid assigning a variable to a multi-line `if`/`unless` block; extract it into a `__method` or use a `case` statement.
          album_bookmarks.find_by(album_id: album_or_identifier.id)
        else
          __find_bookmark_by_identifier(album_or_identifier)
        end
        bookmark
      end
    RUBY
  end

  it "registers an offense for assigning an instance variable to a multi-line unless block" do
    expect_offense(<<~RUBY)
      def load_token
        @token = unless expired?
                 ^^^^^^^^^^^^^^^ Avoid assigning a variable to a multi-line `if`/`unless` block; extract it into a `__method` or use a `case` statement.
          fetch_token
        end
      end
    RUBY
  end

  it "registers an offense for multi-line ||= and &&= assignments" do
    expect_offense(<<~RUBY)
      def cached_value
        @value ||= begin
        ^^^^^^^^^^^^^^^^ Keep `||=` / `&&=` assignments on a single line; extract multi-line logic into a `__method`.
          compute_value
        end
        @other &&= if ready?
        ^^^^^^^^^^^^^^^^^^^^ Keep `||=` / `&&=` assignments on a single line; extract multi-line logic into a `__method`.
          transform(@other)
        end
      end
    RUBY
  end

  it "does not register an offense for single-line ternaries or single-line ||= / &&=" do
    expect_no_offenses(<<~RUBY)
      def resolve(flag)
        result = flag ? :yes : :no
        @cached ||= __compute_cached
        @other &&= __transform(@other)
        [result, @cached, @other]
      end
    RUBY
  end

  it "does not register an offense for assigning to a case statement" do
    expect_no_offenses(<<~RUBY)
      def find_bookmark(album_or_identifier)
        bookmark = case album_or_identifier
        when Album then album_bookmarks.find_by(album_id: album_or_identifier.id)
        else
          __find_bookmark_by_identifier(album_or_identifier)
        end
        bookmark
      end
    RUBY
  end

  it "does not register an offense for assigning to a __method call" do
    expect_no_offenses(<<~RUBY)
      def unbookmark_album!(album_or_identifier)
        bookmark = __find_album_bookmark(album_or_identifier)
        bookmark
      end
    RUBY
  end
end
