require 'test_helper'

require 'wsdl_mapper/type_mapping/string'

module TypeMappingTests
  class StringTest < ::Minitest::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby
      assert_equal "foo", String.to_ruby("foo")
    end

    def test_to_xml
      assert_equal "foo", String.to_xml("foo")
      assert_equal "foo", String.to_xml(:foo)
      assert_equal "1", String.to_xml(1)
      assert_equal "1.23", String.to_xml(1.23)
    end
  end
end
