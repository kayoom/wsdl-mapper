require 'test_helper'

require 'wsdl_mapper/schema/parser'

module SchemaTests
  module ParserTests
    class SimpleExamplesTest < Minitest::Test
      include WsdlMapper::Schema
      include WsdlMapper::Dom

      def test_example_1_complex_type
        schema = TestHelper.parse_schema 'example_1.xsd'

        assert_equal 1, schema.types.count

        type = schema.types.values.first

        assert_kind_of ComplexType, type
        assert_equal Name.new(nil, 'noteType'), type.name

        refute_nil type.documentation
      end

      def test_example_2_complex_type_w_documentation
        schema = TestHelper.parse_schema 'example_2.xsd'
        type = schema.types.values.first

        assert_equal "This is some documentation for type.", type.documentation.default
      end

      def test_example_1_properties_sequence
        schema = TestHelper.parse_schema 'example_1.xsd'
        type = schema.types.values.first

        assert_equal 4, type.properties.count

        props = type.properties.values

        prop_names = props.map { |p| p.name.name }
        assert_includes prop_names, 'to'
        assert_includes prop_names, 'from'
        assert_includes prop_names, 'heading'
        assert_includes prop_names, 'body'

        assert_equal 0, props[0].sequence
        assert_equal 1, props[1].sequence
        assert_equal 2, props[2].sequence
        assert_equal 3, props[3].sequence

        props.each do |prop|
          assert_equal 1, prop.bounds.min
          assert_equal 1, prop.bounds.max
        end
      end

      def test_example_2_unbounded_property
        schema = TestHelper.parse_schema 'example_2.xsd'
        type = schema.types.values.first

        prop = type.properties.values.first

        assert_equal 1, prop.bounds.min
        assert_equal nil, prop.bounds.max
      end

      def test_example_2_optional_property
        schema = TestHelper.parse_schema 'example_2.xsd'
        type = schema.types.values.first

        prop = type.properties.values[2]

        assert_equal 0, prop.bounds.min
        assert_equal 1, prop.bounds.max
      end

      def test_example_2_property_wo_documentation
        schema = TestHelper.parse_schema 'example_2.xsd'
        type = schema.types.values.first

        prop = type.properties.values[1]

        refute_nil prop.documentation
        assert_nil prop.documentation.default
      end

      def test_example_2_property_w_documentation
        schema = TestHelper.parse_schema 'example_2.xsd'
        type = schema.types.values.first

        prop = type.properties.values[3]

        assert_equal "This is some documentation.", prop.documentation.default

        app_info = "This is some appinfo.<link>http://example.com</link>"
        assert_equal app_info, prop.documentation.app_info
      end

      def test_example_4_simple_enum
        schema = TestHelper.parse_schema 'example_4.xsd'
        type = schema.types.values.first

        assert_instance_of SimpleType, type

        base_type = schema.get_type Name.new(Xsd::NS, 'token')

        assert_equal base_type, type.base

        assert_equal 2, type.enumeration_values.count

        expected_enums = [EnumerationValue.new('ship'), EnumerationValue.new('bill')]
        assert_includes expected_enums, type.enumeration_values.first
        assert_includes expected_enums, type.enumeration_values.last
      end

      def test_example_5_complex_type_simple_content
        schema = TestHelper.parse_schema 'example_5.xsd'
        type = schema.types.values.first

        assert_instance_of ComplexType, type

        base_type = schema.get_type Name.new(Xsd::NS, 'float')

        assert_equal base_type, type.base

        attr = type.attributes.values.first
        assert_equal "currency", attr.name
      end

      def test_example_6_complex_type_properties_all
        schema = TestHelper.parse_schema 'example_6.xsd'
        type = schema.types.values.first

        assert_equal 2, type.properties.count

        props = type.properties.values

        user_name_prop = props.first
        assert_equal 'userName', user_name_prop.name.name
        assert_equal 1, user_name_prop.bounds.min
        assert_equal 1, user_name_prop.bounds.max

        password_prop = props.last
        assert_equal 'password', password_prop.name.name
        assert_equal 0, password_prop.bounds.min
        assert_equal 1, password_prop.bounds.max
      end

      # def test_sandbox
      #   doc = TestHelper.get_xml_doc 'ebaySvc.xsd'
      #
      #   names = []
      #   doc.root.traverse do |node|
      #     ns = node.namespace && node.namespace.href
      #     name = Name.new ns, node.name
      #
      #     names << name
      #   end
      #
      #   names.uniq!
      #   names.sort_by! &:to_s
      #
      #   puts names
      # end
    end
  end
end
