require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/generation/generator'

module GenerationTests
  module GeneratorTests
    class SimpleTest < Minitest::Test
      def setup
        @tmp_path = TestHelper.get_tmp_path
      end

      def teardown
        @tmp_path.unlink
      end

      def test_simple_class_generation
        schema = TestHelper.parse_schema 'example_1.xsd'
        context = WsdlMapper::Generation::Context.new @tmp_path.to_s
        generator = WsdlMapper::Generation::Generator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
class NoteType
  attr_accessor :to, :from, :heading, :body
end
RUBY
      end

      def test_simple_class_generation_with_modules
        schema = TestHelper.parse_schema 'example_1.xsd'
        context = WsdlMapper::Generation::Context.new @tmp_path.to_s
        generator = WsdlMapper::Generation::Generator.new context, namer: WsdlMapper::Naming::DefaultNamer.new(module_path: %w[NotesApi Types])

        result = generator.generate schema

        expected_file = @tmp_path.join("notes_api", "types", "note_type.rb")
        assert File.exists? expected_file
        assert_includes result.files, expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
module NotesApi
  module Types
    class NoteType
      attr_accessor :to, :from, :heading, :body
    end
  end
end
RUBY

        root_node = result.module_tree.first
        assert_equal "NotesApi", root_node.type_name.module_name
        middle_node = root_node.children.first
        assert_equal "Types", middle_node.type_name.module_name
        type_node = middle_node.children.first
        assert_equal "NoteType", type_node.type_name.class_name

        expected_file = @tmp_path.join("notes_api", "types.rb")
        assert File.exists? expected_file

        generated_file = File.read expected_file
        assert_equal <<RUBY, generated_file
require 'notes_api/types/note_type'
RUBY

        expected_file = @tmp_path.join("notes_api.rb")
        assert File.exists? expected_file

        generated_file = File.read expected_file
        assert_equal <<RUBY, generated_file
require 'notes_api/types'
RUBY
      end
    end
  end
end
