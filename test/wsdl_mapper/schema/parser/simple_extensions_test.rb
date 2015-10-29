require 'test_helper'

require 'wsdl_mapper/schema/parser'

module SchemaTests
  module ParserTests
    class SimpleExtensionsTest < Minitest::Test
      include WsdlMapper::Schema
      include WsdlMapper::Dom

      def test_example_3_simple_extension
        schema = TestHelper.parse_schema 'basic_note_type_and_fancy_note_type_extension.xsd'

        assert_equal 2, schema.types.count

        base_type = schema.types.values.first
        extended_type = schema.types.values.last

        assert_equal Name.new(nil, 'noteType'), base_type.name
        assert_equal Name.new(nil, 'fancyNoteType'), extended_type.name
        assert_equal base_type, extended_type.base

        assert_equal 1, extended_type.properties.count
      end

      def test_example_3_simple_extension_with_ns
        schema = TestHelper.parse_schema 'basic_note_type_and_fancy_note_type_extension_with_namespace.xsd'
        ns = 'example.org/example_3'

        assert_equal ns, schema.target_namespace

        assert_equal 2, schema.types.count

        base_type = schema.types.values.first
        extended_type = schema.types.values.last

        assert_equal Name.new(ns, 'noteType'), base_type.name
        assert_equal Name.new(ns, 'fancyNoteType'), extended_type.name
        assert_equal base_type, extended_type.base

        assert_equal 1, extended_type.properties.count
        prop = extended_type.properties.values.first

        assert_equal 'attachments', prop.name.name
      end
    end
  end
end

