require 'test_helper'

require 'wsdl_mapper/dom/builtin_type'

module DomTests
  class BuiltinTypeTest < Minitest::Test
    include WsdlMapper::Dom

    def test_index_accessor
      type = BuiltinType[:string]

      refute_nil type
      assert_equal 'string', type.name.name
    end

    def test_enumeration
      BuiltinType.types.clear
      BuiltinType[:string]
      BuiltinType[:int]
      BuiltinType[:decimal]

      assert_equal 3, BuiltinType.each.count
    end
  end
end
