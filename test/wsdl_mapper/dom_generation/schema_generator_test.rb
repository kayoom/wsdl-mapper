require 'test_helper'

require 'wsdl_mapper/dom_parsing/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'

module DomGenerationTests
  module GeneratorTests
    class SchemaGeneratorTest < GenerationTest
      include WsdlMapper::DomGeneration

      def generate(name, module_path)
        schema = TestHelper.parse_schema name
        generator = SchemaGenerator.new context, namer: WsdlMapper::Naming::DefaultNamer.new(module_path: module_path)
        generator.generate schema
      end

      def test_simple_class_generation_with_modules
        result = generate 'basic_note_type.xsd', %w[NotesApi Types]

        assert_includes result.files, path_for('notes_api', 'types', 'note_type.rb')

        assert_file_is 'notes_api', 'types', 'note_type.rb', <<RUBY
module NotesApi
  module Types
    class NoteType
      attr_accessor :to
      attr_accessor :from
      attr_accessor :heading
      attr_accessor :body
    end
  end
end
RUBY

        root_node = result.module_tree.first
        assert_equal 'NotesApi', root_node.type_name.module_name
        middle_node = root_node.children.first
        assert_equal 'Types', middle_node.type_name.module_name
        type_node = middle_node.children.first
        assert_equal 'NoteType', type_node.type_name.class_name

        assert_file_is 'notes_api', 'types.rb', <<RUBY
require "notes_api/types/note_type"
RUBY

        assert_file_is 'notes_api.rb', <<RUBY
require "notes_api/types"
RUBY
      end
    end
  end
end
