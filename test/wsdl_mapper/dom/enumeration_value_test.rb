require 'test_helper'

require 'wsdl_mapper/dom/enumeration_value'

module DomTests
  class EnumerationValueTest < WsdlMapperTesting::Test
    include WsdlMapper::Dom

    def test_value_accessors
      enum = EnumerationValue.new 'foo'
      assert_equal 'foo', enum.value
    end
  end
end
