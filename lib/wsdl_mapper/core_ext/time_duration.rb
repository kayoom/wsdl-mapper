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
        @negative
      end
    end
  end
end
