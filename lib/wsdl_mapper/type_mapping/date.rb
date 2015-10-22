require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module TypeMapping
    Date = Base.new do
      register_xml_types %w[
        date
      ]

      def to_ruby string
        ::DateTime.parse string.to_s
      end

      def to_xml object
        object.strftime "%F%:z"
      end
    end
  end
end
