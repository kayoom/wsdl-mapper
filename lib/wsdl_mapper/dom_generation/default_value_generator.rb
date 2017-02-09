require 'bigdecimal'

require 'wsdl_mapper/core_ext/time_duration'

module WsdlMapper
  module DomGeneration
    class DefaultValueGenerator
      def generate_string(string)
        string.to_s.inspect
      end

      def generate_integer(int)
        int.to_i.inspect
      end

      def generate_big_decimal(decimal)
        "::BigDecimal.new(#{decimal.to_s.inspect})"
      end

      def generate_date(date)
        "::Date.new(#{date.year}, #{date.month}, #{date.day})"
      end

      def generate_date_time(date_time)
        "::DateTime.parse(#{date_time.to_s.inspect})"
      end

      def generate_time(time)
        "::Time.parse(#{time.to_s.inspect})"
      end

      def generate_float(float)
        float.inspect
      end

      def generate_boolean(bool)
        bool.inspect
      end

      def generate_time_duration(td)
        "::WsdlMapper::CoreExt::TimeDuration.new(years: #{td.years}, months: #{td.months}, days: #{td.days}, hours: #{td.hours}, minutes: #{td.minutes}, seconds: #{td.seconds}, negative: #{generate_boolean(td.negative?)})"
      end

      def generate_nil
        'nil'
      end

      def generate_empty_array
        '[]'
      end

      def generate(obj)
        case obj
        when ::Integer
          generate_integer obj
        when ::String
          generate_string obj
        when ::BigDecimal
          generate_big_decimal obj
        when ::DateTime
          generate_date_time obj
        when ::Date
          generate_date obj
        when ::Time
          generate_time obj
        when ::Float
          generate_float obj
        when ::TrueClass, ::FalseClass
          generate_boolean obj
        when ::WsdlMapper::CoreExt::TimeDuration
          generate_time_duration obj
        when ::NilClass
          generate_nil
        when []
          generate_empty_array
        else
          raise ArgumentError.new("Unknown type: #{obj}")
        end
      end
    end
  end
end
