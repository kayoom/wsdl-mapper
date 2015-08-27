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

      assert_kind_of Type, type
      assert_equal Name.new(nil, 'noteType'), type.name
    end

    def test_complex_type_properties
      schema = build_from_fixture 'example_1'
      type = schema.types.values.first

      assert_equal 4, type.properties.count
    end
  end
end
