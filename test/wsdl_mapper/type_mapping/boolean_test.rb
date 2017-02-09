require 'test_helper'

require 'wsdl_mapper/type_mapping/boolean'

module TypeMappingTests
  class BooleanTest < ::WsdlMapperTesting::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby
      assert_equal true, Boolean.to_ruby('true')
      assert_equal true, Boolean.to_ruby('1')
      assert_equal false, Boolean.to_ruby('false')
      assert_equal false, Boolean.to_ruby('0')
    end

    def test_to_xml
      assert_equal 'true', Boolean.to_xml(true)
      assert_equal 'false', Boolean.to_xml(false)
    end

    def test_ruby_type
      assert_nil Boolean.ruby_type
    end
  end
end
