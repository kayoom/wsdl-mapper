require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

require 'bigdecimal'

module WsdlMapper
  module TypeMapping
    Boolean = Base.new do
      register_xml_types %w[
        boolean
      ]

      def to_ruby(string)
        case string.to_s
        when "true", "1"
          true
        when "false", "0"
          false
        end
      end

      def to_xml(object)
        object ? "true" : "false"
      end

      def ruby_type
        nil
      end
    end
  end
end
