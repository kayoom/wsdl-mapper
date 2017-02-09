require 'test_helper'

require 'wsdl_mapper/dom_generation/default_value_generator'

require 'bigdecimal'

module DomGenerationTests
  module GeneratorTests
    class DefaultValueGeneratorTest < ::WsdlMapperTesting::Test
      include WsdlMapper::Generation
      include WsdlMapper::DomGeneration
      include WsdlMapper::CoreExt

      def assert_evalable(origin, type)
        evalable = DefaultValueGenerator.new.send "generate_#{type}", origin
        assert_equal origin, eval(evalable)

        evalable = DefaultValueGenerator.new.generate origin
        assert_equal origin, eval(evalable)
      end

      def test_simple_string
        assert_evalable 'foo bar', :string
        assert_evalable "foo\tb\"ar\n", :string
        assert_evalable "foo\u00B6bar\u040E\u0601", :string
      end

      def test_simple_integer
        assert_evalable 1, :integer
        assert_evalable -1, :integer
        assert_evalable 12345667890123, :integer
      end

      def test_simple_decimal
        assert_evalable BigDecimal.new('-123.45'), :big_decimal
      end

      def test_date
        assert_evalable Date.new(1999, 10, 9), :date
      end

      def test_date_time
        assert_evalable DateTime.new(1999, 10, 9, 8, 7, 6, '+03:00'), :date_time
        assert_evalable DateTime.new(1999, 10, 9, 8, 7, 6), :date_time
      end

      def test_time
        assert_evalable Time.new(1999, 10, 9, 8, 7, 6, '+03:00'), :time
        assert_evalable Time.new(1999, 10, 9, 8, 7, 6), :time
      end

      def test_float
        assert_evalable -123.456789, :float
      end

      def test_boolean
        assert_evalable true, :boolean
        assert_evalable false, :boolean
      end

      def test_time_duration
        assert_evalable TimeDuration.new(years: 2, days: 3, minutes: 4), :time_duration
      end

      def test_nil
        evalable = DefaultValueGenerator.new.generate_nil

        assert_equal nil, eval(evalable)
      end
    end
  end
end
