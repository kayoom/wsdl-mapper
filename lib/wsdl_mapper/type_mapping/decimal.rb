require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

require 'bigdecimal'

module WsdlMapper
  module TypeMapping
    Decimal = Base.new do
      register_xml_types %w[
        decimal
      ]

      def to_ruby string
        BigDecimal.new string.to_s
      end

      def to_xml object
        object.to_s 'F'
      end

      def ruby_type
        BigDecimal
      end

      def requires
        ['bigdecimal']
      end
    end
  end
end
