require 'test_helper'

require 'wsdl_mapper/type_mapping/date_time'

module TypeMappingTests
  class DateTimeTest < ::Minitest::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby
      assert_equal ::DateTime.new(2002, 5, 30, 9), DateTime.to_ruby("2002-05-30T09:00:00")
      assert_equal ::DateTime.new(2002, 5, 30, 9, 30, 10, '-6'), DateTime.to_ruby("2002-05-30T09:30:10-06:00")
    end

    def test_to_xml
      assert_equal "2002-05-30T09:00:00+00:00", DateTime.to_xml(::DateTime.new(2002, 5, 30, 9))
      assert_equal "2002-05-30T09:30:10-06:00", DateTime.to_xml(::DateTime.new(2002, 5, 30, 9, 30, 10, '-6'))
    end

    def test_ruby_type
      assert_equal ::DateTime, DateTime.ruby_type
    end
  end
end
