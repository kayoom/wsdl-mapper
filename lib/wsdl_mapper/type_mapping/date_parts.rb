require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

require 'wsdl_mapper/core_ext/time_duration'

module WsdlMapper
  module TypeMapping
    module DateParts
      class Base < WsdlMapper::TypeMapping::Base
        def ruby_type
          WsdlMapper::CoreExt::TimeDuration
        end

        def requires
          ['wsdl_mapper/core_ext/time_duration']
        end
      end

      Day = Base.new do
        register_xml_types %w[
          gDay
        ]

        def to_ruby(string)
          WsdlMapper::CoreExt::TimeDuration.new days: string.to_s.to_i
        end

        def to_xml(object)
          '%02d' % object.days
        end
      end

      Month = Base.new do
        register_xml_types %w[
          gMonth
        ]

        def to_ruby(string)
          WsdlMapper::CoreExt::TimeDuration.new months: string.to_s.to_i
        end

        def to_xml(object)
          '%02d' % object.months
        end
      end

      Year = Base.new do
        register_xml_types %w[
          gYear
        ]

        def to_ruby(string)
          WsdlMapper::CoreExt::TimeDuration.new years: string.to_s.to_i
        end

        def to_xml(object)
          '%04d' % object.years
        end
      end

      YearMonth = Base.new do
        register_xml_types %w[
          gYearMonth
        ]

        def to_ruby(string)
          years, months = string.split '-'
          WsdlMapper::CoreExt::TimeDuration.new years: years.to_i, months: months.to_i
        end

        def to_xml(object)
          '%04d-%02d' % [object.years, object.months]
        end
      end

      MonthDay = Base.new do
        register_xml_types %w[
          gMonthDay
        ]

        def to_ruby(string)
          months, days = string.split '-'
          WsdlMapper::CoreExt::TimeDuration.new months: months.to_i, days: days.to_i
        end

        def to_xml(object)
          '%02d-%02d' % [object.months, object.days]
        end
      end
    end
  end
end
