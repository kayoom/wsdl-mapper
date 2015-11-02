require 'test_helper'

require 'wsdl_mapper/dom/simple_type'
require 'wsdl_mapper/dom/name'

module DomTests
  class SimpleTypeTest < Minitest::Test
    include WsdlMapper::Dom

    def test_root_self
      a = SimpleType.new Name.new(nil, 'a')

      assert_equal a, a.root
    end

    def test_root
      a = SimpleType.new Name.new(nil, 'a')
      b = SimpleType.new Name.new(nil, 'b')
      c = SimpleType.new Name.new(nil, 'c')
      a.base = b
      b.base = c

      assert_equal c, a.root
    end
  end
end
