require 'test_helper'

require 'wsdl_mapper/type_mapping/date_parts'

module TypeMappingTests
  module DatePartsTest
    class BaseTest < ::Minitest::Test
      include WsdlMapper::TypeMapping::DateParts
      include WsdlMapper::CoreExt

      def test_ruby_type
        assert_equal TimeDuration, Day.ruby_type
      end
    end

    class DayTest < ::Minitest::Test
      include WsdlMapper::TypeMapping::DateParts
      include WsdlMapper::CoreExt

      def test_to_ruby
        assert_equal TimeDuration.new(days: 14), Day.to_ruby("14")
      end

      def test_to_xml
        assert_equal "04", Day.to_xml(TimeDuration.new(days: 4))
      end
    end

    class MonthTest < ::Minitest::Test
      include WsdlMapper::TypeMapping::DateParts
      include WsdlMapper::CoreExt

      def test_to_ruby
        assert_equal TimeDuration.new(months: 11), Month.to_ruby("11")
      end

      def test_to_xml
        assert_equal "04", Month.to_xml(TimeDuration.new(months: 4))
      end
    end

    class YearTest < ::Minitest::Test
      include WsdlMapper::TypeMapping::DateParts
      include WsdlMapper::CoreExt

      def test_to_ruby
        assert_equal TimeDuration.new(years: 11), Year.to_ruby("0011")
      end

      def test_to_xml
        assert_equal "0004", Year.to_xml(TimeDuration.new(years: 4))
      end
    end

    class YearMonthTest < ::Minitest::Test
      include WsdlMapper::TypeMapping::DateParts
      include WsdlMapper::CoreExt

      def test_to_ruby
        assert_equal TimeDuration.new(years: 11, months: 6), YearMonth.to_ruby("0011-06")
      end

      def test_to_xml
        assert_equal "0004-05", YearMonth.to_xml(TimeDuration.new(years: 4, months: 5))
      end
    end

    class MonthDayTest < ::Minitest::Test
      include WsdlMapper::TypeMapping::DateParts
      include WsdlMapper::CoreExt

      def test_to_ruby
        assert_equal TimeDuration.new(months: 6, days: 9), MonthDay.to_ruby("06-09")
      end

      def test_to_xml
        assert_equal "06-09", MonthDay.to_xml(TimeDuration.new(months: 6, days: 9))
      end
    end
  end
end
