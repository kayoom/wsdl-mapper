require 'test_helper'

require 'wsdl_mapper/generation/default_formatter'

module GenerationTests
  class DefaultFormatterTest < ::Minitest::Test
    def formatter
      @formatter ||= WsdlMapper::Generation::DefaultFormatter.new stream
    end

    def stream
      @stream ||= StringIO.new
    end

    def test_newlines_to_separate_statements
      formatter.next_statement

      assert_equal "\n", stream.string
    end

    def test_any_statement
      formatter.statement "puts 'foo'"

      assert_equal "puts 'foo'\n", stream.string
    end

    def test_method_definition
      formatter.begin_def "do_something", %w[with_this and_that]
      formatter.statement "puts with_this, and_that"
      formatter.end

      expected = <<RUBY

def do_something(with_this, and_that)
  puts with_this, and_that
end
RUBY
      assert_equal expected, stream.string
    end

    def test_method_definition_wo_args
      formatter.begin_def "do_something"
      formatter.statement "puts 'foo bar'"
      formatter.end

      expected = <<RUBY

def do_something
  puts 'foo bar'
end
RUBY
      assert_equal expected, stream.string
    end

    def test_class_definition
      formatter.begin_class "NoteType"
      formatter.statement "include FooBar"
      formatter.end

      expected = <<RUBY
class NoteType
  include FooBar
end
RUBY
      assert_equal expected, stream.string
    end

    def test_module_definition
      formatter.begin_module "NotesApi"
      formatter.statement "extend self"
      formatter.end

      expected = <<RUBY
module NotesApi
  extend self
end
RUBY
      assert_equal expected, stream.string
    end

    def test_nested_module_definition
      formatter.begin_module "NotesApi"
      formatter.begin_module "Types"
      formatter.statement "extend self"
      formatter.end
      formatter.end

      expected = <<RUBY
module NotesApi
  module Types
    extend self
  end
end
RUBY
      assert_equal expected, stream.string
    end
  end
end
