require 'test_helper'

require 'wsdl_mapper/type_mapping/time'

module TypeMappingTests
  class TimeTest < ::WsdlMapperTesting::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby
      time = Time.to_ruby("02:03:04+05:00")
      assert_equal 2, time.hour
      assert_equal 3, time.min
      assert_equal 4, time.sec
      assert_equal 18000, time.utc_offset
    end

    def test_to_xml
      time = ::Time.new 2002, 10, 31, 2, 3, 4, "+05:00"
      assert_equal "02:03:04+05:00", Time.to_xml(time)

      time = ::DateTime.new 2002, 10, 31, 2, 3, 4, "+05:00"
      assert_equal "02:03:04+05:00", Time.to_xml(time)
    end

    def test_ruby_type
      assert_equal ::Time, Time.ruby_type
    end
  end
end
