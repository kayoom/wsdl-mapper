module WsdlMapper
  module CoreExt
    # A very simple representation of time durations.
    # The implementation is very naive. Each component (years, months, etc...) is stored separately
    # and equality is only given, if all components are the same:
    # ```ruby
    # TimeDuration.new(years: 1) == TimeDuration.new(months: 12)
    # #=> false
    # ```
    # Furthermore, comparison (`<=>`) does not work if you use unnormalized durations (e.g. 15 months instead of 1 year, 3 months):
    # ```ruby
    # TimeDuration.new(years: 1, months: 2) < TimeDuration.new(months: 15)
    # #=> false
    # ```
    class TimeDuration
      # @!attribute years
      #   @return [Fixnum] This durations years
      # @!attribute months
      #   @return [Fixnum] This durations months
      # @!attribute days
      #   @return [Fixnum] This durations days
      # @!attribute hours
      #   @return [Fixnum] This durations hours
      # @!attribute minutes
      #   @return [Fixnum] This durations minutes
      # @!attribute seconds
      #   @return [Fixnum] This durations seconds
      # @!attribute negative
      #   @return [true, false] Is this duration negative?
      attr_accessor :years, :months, :days, :hours, :minutes, :seconds, :negative

      # @param [bool] negative Set if negative or not
      # @param [Fixnum] years Sets the years
      # @param [Fixnum] months Sets the months
      # @param [Fixnum] days Sets the days
      # @param [Fixnum] hours Sets the hours
      # @param [Fixnum] minutes Sets the minutes
      # @param [Fixnum] seconds Sets the seconds
      def initialize(negative: false, years: 0, months: 0, days: 0, hours: 0, minutes: 0, seconds: 0)
        @seconds = seconds
        @minutes = minutes
        @hours = hours
        @days = days
        @months = months
        @years = years
        @negative = negative
      end

      # Check if this is a negative duration
      # @return [true, false]
      def negative?
        !!@negative
      end

      # @private
      def hash
        [negative?, years, months, days, hours, minutes, seconds].hash
      end

      # @private
      def eql?(other)
        return false unless other.is_a?(TimeDuration)

        negative? == other.negative? &&
          years == other.years &&
          months == other.months &&
          days == other.days &&
          hours == other.hours &&
          minutes == other.minutes &&
          seconds == other.seconds
      end

      # @private
      def ==(other)
        eql? other
      end

      # @private
      def <=>(other)
        return -1 if negative? and !other.negative?
        return 1 if !negative? and other.negative?

        fields = [:years, :months, :days, :hours, :minutes, :seconds]
        fields.each do |field|
          c = send(field) <=> other.send(field)
          return c if c != 0
        end
        return 0
      end

      # @private
      def >(other)
        (self <=> other) > 0
      end

      # @private
      def >=(other)
        (self <=> other) >= 0
      end

      # @private
      def <(other)
        (self <=> other) < 0
      end

      # @private
      def <=(other)
        (self <=> other) <= 0
      end
    end
  end
end
