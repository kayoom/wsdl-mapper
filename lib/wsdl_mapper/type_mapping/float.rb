require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module TypeMapping
    Float = Base.new do
      register_xml_types %w[
        float
        double
      ]

      def to_ruby(string)
        string.to_s.to_f
      end

      def to_xml(object)
        case object
        when ::Float, ::Integer
          object.to_s
        when Rational, BigDecimal
          object.to_f.to_s
        end
      end

      def ruby_type
        ::Float
      end
    end
  end
end
