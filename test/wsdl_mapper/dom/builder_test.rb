require 'test_helper'

require 'wsdl_mapper/dom/builder'

module DomTests
  class BuilderTest < Minitest::Test
    include WsdlMapper::Dom

    def build_from_fixture name
      xsd_file = WsdlMapper::Schema::XsdFile.new TestHelper.get_fixture("#{name}.xsd")
      builder = Builder.new xsd_file

      builder.build
    end

    def test_that_it_returns_a_schema
      schema = build_from_fixture 'w3_example'

      assert_kind_of Schema, schema
    end

    def test_a_complex_type
      schema = build_from_fixture 'example_1'

      assert_equal 1, schema.types.count

      type = schema.types.values.first

      assert_kind_of ComplexType, type
      assert_equal Name.new(nil, 'noteType'), type.name
    end

    def test_complex_type_properties
      schema = build_from_fixture 'example_1'
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

    # def test_complex_type_property_bounds
    #   skip
    #   schema = build_from_fixture 'example_2'
    #   type = schema.types.values.first
    #
    #   props = type.properties.values
    #
    #   to_prop = props.find { |p| p.name.name == 'to' }
    #   heading_prop = props.find { |p| p.name.name == 'heading' }
    #
    #   assert_equal -1, to_prop.bounds.max
    #   assert_equal 0, heading_prop.bounds.min
    # end
  end
end
