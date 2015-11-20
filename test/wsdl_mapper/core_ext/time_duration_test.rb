require 'test_helper'

require 'wsdl_mapper/core_ext/time_duration'

module CoreExtTests
  class TimeDurationTest < ::WsdlMapperTesting::Test
    include WsdlMapper::CoreExt

    def test_equality
      a = TimeDuration.new years: 1, months: 2
      b = TimeDuration.new years: 1, months: 2

      assert a == b
      assert a.eql?(b)
    end

    def test_hash_key_equality
      a = TimeDuration.new years: 1, months: 2
      b = TimeDuration.new years: 1, months: 2

      hash = {
        a => 'foo'
      }

      assert_equal 'foo', hash[b]
    end

    def test_comparison_positive_negative
      a = TimeDuration.new years: 2, negative: true
      b = TimeDuration.new years: 1

      assert_equal -1, a <=> b
      assert_equal 1, b <=> a
    end

    def test_fields_comparison
      a = TimeDuration.new years: 2
      b = TimeDuration.new years: 1
      c = TimeDuration.new years: 1

      assert_equal 1, a <=> b
      assert_equal 0, c <=> b
    end

    def test_fields_of_diff_magnitude_comparison
      a = TimeDuration.new months: 2
      b = TimeDuration.new years: 1

      assert_equal -1, a <=> b


      a = TimeDuration.new days: 2
      b = TimeDuration.new years: 1

      assert_equal -1, a <=> b


      a = TimeDuration.new hours: 2
      b = TimeDuration.new days: 1

      assert_equal -1, a <=> b
    end

    def test_gte_lte
      a = TimeDuration.new months: 2
      b = TimeDuration.new years: 1
      c = TimeDuration.new years: 1

      assert b > a
      assert b >= a
      assert b >= c

      a = TimeDuration.new months: 2
      b = TimeDuration.new years: 1
      c = TimeDuration.new years: 1

      assert a < b
      assert a <= b
      assert b <= c
    end
  end
end
