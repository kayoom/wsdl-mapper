require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/generation/schema_generator'

module GenerationTests
  module GeneratorTests
    class SimpleClassGeneratorTest < Minitest::Test
      def setup
        @tmp_path = TestHelper.get_tmp_path
      end

      def teardown
        @tmp_path.unlink
      end

      def test_empty_properties
        schema = TestHelper.parse_schema 'example_11.xsd'
        context = WsdlMapper::Generation::Context.new @tmp_path.to_s
        generator = WsdlMapper::Generation::SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
class NoteType
end
RUBY
      end

      def test_simple_class_generation
        schema = TestHelper.parse_schema 'example_1.xsd'
        context = WsdlMapper::Generation::Context.new @tmp_path.to_s
        generator = WsdlMapper::Generation::SchemaGenerator.new context

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

      def test_sub_class_generation
        schema = TestHelper.parse_schema 'example_3.xsd'
        context = WsdlMapper::Generation::Context.new @tmp_path.to_s
        generator = WsdlMapper::Generation::SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("fancy_note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
require "note_type"

class FancyNoteType < ::NoteType
  attr_accessor :attachments
end
RUBY
      end

      def test_simple_class_generation_with_modules
        schema = TestHelper.parse_schema 'example_1.xsd'
        context = WsdlMapper::Generation::Context.new @tmp_path.to_s
        generator = WsdlMapper::Generation::SchemaGenerator.new context, namer: WsdlMapper::Naming::DefaultNamer.new(module_path: %w[NotesApi Types])

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
require "notes_api/types/note_type"
RUBY

        expected_file = @tmp_path.join("notes_api.rb")
        assert File.exists? expected_file

        generated_file = File.read expected_file
        assert_equal <<RUBY, generated_file
require "notes_api/types"
RUBY
      end

      def test_simple_class_generation_with_require_of_property_types
        schema = TestHelper.parse_schema 'example_10.xsd'
        context = WsdlMapper::Generation::Context.new @tmp_path.to_s
        generator = WsdlMapper::Generation::SchemaGenerator.new context, namer: WsdlMapper::Naming::DefaultNamer.new(module_path: %w[OrdersApi Types])

        result = generator.generate schema
        expected_file = @tmp_path.join("orders_api", "types", "order_type.rb")

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
require "orders_api/types/address_type"

module OrdersApi
  module Types
    class OrderType
      attr_accessor :name, :street, :type
    end
  end
end
RUBY
      end
    end
  end
end
