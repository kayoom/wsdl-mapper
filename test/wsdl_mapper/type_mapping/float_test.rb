require 'test_helper'

require 'wsdl_mapper/type_mapping/float'

require 'bigdecimal'

module TypeMappingTests
  class FloatTest < ::WsdlMapperTesting::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby
      assert_equal -123.45, Float.to_ruby('-123.45')
    end

    def test_to_xml
      assert_equal '-123.45', Float.to_xml(-123.45)
      assert_equal '0.3', Float.to_xml('3/10'.to_r)
      assert_equal '3', Float.to_xml(3)
      assert_equal '123.45', Float.to_xml(BigDecimal.new('123.45'))
    end

    def test_ruby_type
      assert_equal ::Float, Float.ruby_type
    end
  end
end

