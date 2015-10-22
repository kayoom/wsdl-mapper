require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module TypeMapping
    DateTime = Base.new do
      register_xml_types %w[
        dateTime
      ]

      def to_ruby string
        ::DateTime.parse string.to_s
      end

      def to_xml object
        object.to_s
      end
    end
  end
end
