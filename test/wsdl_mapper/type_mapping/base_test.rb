require 'test_helper'

require 'wsdl_mapper/type_mapping/base'

module TypeMappingTests
  class BaseTest < ::Minitest::Test
    TestMapping = WsdlMapper::TypeMapping::Base.new do
      register_xml_types %w[int integer]
    end

    def test_recognition_of_xml_type_name
      type = WsdlMapper::Dom::BuiltinType['int']

      assert TestMapping.maps? type.name
    end

    def test_recognition_of_xml_type
      type = WsdlMapper::Dom::BuiltinType['int']

      assert TestMapping.maps? type
    end

    def test_falses
      refute TestMapping.maps? 'foo'
      refute TestMapping.maps? 123.45
      refute TestMapping.maps? :foo

      type = WsdlMapper::Dom::BuiltinType['string']
      refute TestMapping.maps? type
    end

    def test_abstract_methods
      assert_raises(NotImplementedError) { TestMapping.to_xml(1) }
      assert_raises(NotImplementedError) { TestMapping.to_ruby("1") }
    end
  end
end
