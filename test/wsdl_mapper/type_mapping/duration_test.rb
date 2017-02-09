require 'test_helper'

require 'wsdl_mapper/type_mapping/duration'

module TypeMappingTests
  class DurationTest < ::WsdlMapperTesting::Test
    include WsdlMapper::TypeMapping
    include WsdlMapper::CoreExt

    def test_to_ruby
      duration = Duration.to_ruby '-P5Y2M10DT15H6M2S'

      assert_equal true, duration.negative?
      assert_equal 5, duration.years
      assert_equal 2, duration.months
      assert_equal 10, duration.days
      assert_equal 15, duration.hours
      assert_equal 6, duration.minutes
      assert_equal 2, duration.seconds
    end

    def test_to_xml
      assert_equal 'P5Y', Duration.to_xml(TimeDuration.new(years: 5))
      assert_equal 'P5Y2M10D', Duration.to_xml(TimeDuration.new(years: 5, months: 2, days: 10))
      assert_equal 'P5Y2M10DT15H12M6S', Duration.to_xml(TimeDuration.new(years: 5, months: 2, days: 10, hours: 15, minutes: 12, seconds: 6))
      assert_equal '-P5Y2M10DT15H12M6S', Duration.to_xml(TimeDuration.new(years: 5, months: 2, days: 10, hours: 15, minutes: 12, seconds: 6, negative: true))
      assert_equal 'PT15H6S', Duration.to_xml(TimeDuration.new(hours: 15, seconds: 6))
    end

    def test_ruby_type
      assert_equal TimeDuration, Duration.ruby_type
    end
  end
end
