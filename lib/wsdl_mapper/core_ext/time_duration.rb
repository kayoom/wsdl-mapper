module WsdlMapper
  module CoreExt
    class TimeDuration
      attr_accessor :years, :months, :days, :hours, :minutes, :seconds, :negative

      def initialize negative: false, years: 0, months: 0, days: 0, hours: 0, minutes: 0, seconds: 0
        @seconds = seconds
        @minutes = minutes
        @hours = hours
        @days = days
        @months = months
        @years = years
        @negative = negative
      end

      def negative?
        !!@negative
      end

      def hash
        [negative?, years, months, days, hours, minutes, seconds].hash
      end

      def eql? other
        return false unless other.is_a?(TimeDuration)

        negative? == other.negative? &&
          years == other.years &&
          months == other.months &&
          days == other.days &&
          hours == other.hours &&
          minutes == other.minutes &&
          seconds == other.seconds
      end

      def == other
        eql? other
      end

      def <=> other
        return -1 if negative? and !other.negative?
        return 1 if !negative? and other.negative?

        fields = [:years, :months, :days, :hours, :minutes, :seconds]
        fields.each do |field|
          c = send(field) <=> other.send(field)
          return c if c != 0
        end
        return 0
      end

      def > other
        (self <=> other) > 0
      end

      def >= other
        (self <=> other) >= 0
      end

      def < other
        (self <=> other) < 0
      end

      def <= other
        (self <=> other) <= 0
      end
    end
  end
end
