require 'test_helper'

require 'wsdl_mapper/type_mapping/integer'

module TypeMappingTests
  class IntegerTest < ::WsdlMapperTesting::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby
      assert_equal 1, Integer.to_ruby('1')
      assert_equal 1, Integer.to_ruby(1)

      assert_equal -1, Integer.to_ruby('-1')

      assert_equal 1234567891234, Integer.to_ruby('1234567891234')

      assert_equal 1, Integer.to_ruby('1.23')
    end

    def test_to_xml
      assert_equal '1', Integer.to_xml(1)
      assert_equal '1', Integer.to_xml('1')

      assert_equal '-1', Integer.to_xml(-1)

      assert_equal '1234567891234', Integer.to_xml(1234567891234)

      assert_equal '1', Integer.to_xml(1.23)
      assert_equal '1', Integer.to_xml('1.23')
    end

    def test_ruby_type
      assert_equal ::Fixnum, Integer.ruby_type
    end
  end
end
