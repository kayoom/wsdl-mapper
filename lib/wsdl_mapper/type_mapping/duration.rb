require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

require 'wsdl_mapper/core_ext/time_duration'

module WsdlMapper
  module TypeMapping
    Duration = Base.new do
      register_ruby_types [
        WsdlMapper::CoreExt::TimeDuration
      ]

      register_xml_types %w[
        duration
      ]

      def to_ruby string
        duration = WsdlMapper::CoreExt::TimeDuration.new
        value = ""
        negative = false
        time = false

        string.to_s.each_char do |chr|
          case chr
          when '-'
            negative = true
          when 'P'
            duration.negative = negative
          when 'T'
            time = true
          when 'Y'
            duration.years = value.to_i
            value = ""
          when 'M'
            if time
              duration.minutes = value.to_i
            else
              duration.months = value.to_i
            end
            value = ""
          when 'D'
            duration.days = value.to_i
            value = ""
          when "H"
            duration.hours = value.to_i
            value = ""
          when "S"
            duration.seconds = value.to_i
            value = ""
          else
            value += chr
          end
        end

        duration
      end

      def to_xml object
        buf = ""

        add_period buf, object
        add_date buf, object
        add_time buf, object

        buf
      end

      def add_period buf, d
        buf << "-" if d.negative?
        buf << "P"
      end

      def add_date buf, d
        if d.years > 0
          buf << d.years.to_s
          buf << "Y"
        end

        if d.months > 0
          buf << d.months.to_s
          buf << "M"
        end

        if d.days > 0
          buf << d.days.to_s
          buf << "D"
        end
      end

      def add_time buf, d
        return unless [d.hours, d.minutes, d.seconds].any? { |t| t > 0 }
        buf << "T"

        if d.hours > 0
          buf << d.hours.to_s
          buf << "H"
        end

        if d.minutes > 0
          buf << d.minutes.to_s
          buf << "M"
        end

        if d.seconds > 0
          buf << d.seconds.to_s
          buf << "S"
        end
      end
    end
  end
end
