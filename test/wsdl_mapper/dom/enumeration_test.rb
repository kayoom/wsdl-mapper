require 'test_helper'

require 'wsdl_mapper/dom/enumeration'

module DomTests
  class EnumerationTest < Minitest::Test
    include WsdlMapper::Dom

    def test_value_accessors
      enum = Enumeration.new 'foo'
      assert_equal 'foo', enum.value
    end
  end
end
