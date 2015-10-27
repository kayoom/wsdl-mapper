module WsdlMapper
  module Generation
    class ValueGenerator
      def generate_string string
        string.to_s.inspect
      end

      def generate_integer int
        int.to_i.inspect
      end

      def generate_big_decimal decimal
        "::BigDecimal.new(#{decimal.to_s.inspect})"
      end

      def generate_date date
        "::Date.new(#{date.year}, #{date.month}, #{date.day})"
      end

      def generate_date_time date_time
        "::DateTime.parse(#{date_time.to_s.inspect})"
      end

      def generate_time time
        "::Time.parse(#{time.to_s.inspect})"
      end

      def generate_float float
        float.inspect
      end

      def generate_boolean bool
        bool.inspect
      end

      def generate_time_duration td
        "::WsdlMapper::CoreExt::TimeDuration.new(years: #{td.years}, months: #{td.months}, days: #{td.days}, hours: #{td.hours}, minutes: #{td.minutes}, seconds: #{td.seconds}, negative: #{generate_boolean(td.negative?)})"
      end
    end
  end
end
