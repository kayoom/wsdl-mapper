require 'test_helper'

require 'wsdl_mapper/type_mapping/date'

module TypeMappingTests
  class DateTest < ::WsdlMapperTesting::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby
      assert_equal ::DateTime.new(2002, 5, 30, 0), Date.to_ruby('2002-05-30')
      assert_equal ::DateTime.new(2002, 5, 30, 0, 0, 0, '-6'), Date.to_ruby('2002-05-30-06:00')
    end

    def test_to_xml
      assert_equal '2002-05-30+00:00', Date.to_xml(::DateTime.new(2002, 5, 30))
      assert_equal '2002-05-30-06:00', Date.to_xml(::DateTime.new(2002, 5, 30, 0, 0, 0, '-6'))
    end

    def test_ruby_type
      assert_equal ::DateTime, Date.ruby_type
    end
  end
end
