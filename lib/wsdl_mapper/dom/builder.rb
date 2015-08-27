require 'wsdl_mapper/dom/schema'
require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/dom/type'

module WsdlMapper
  module Dom
    class Builder
      def initialize xsd_file
        @xsd_file = xsd_file
      end

      def build
        schema = Schema.new

        @xsd_file.complex_types.each do |xsd_type|
          schema.add_type build_type(xsd_type)
        end

        schema
      end

      def build_type xsd_type
        name = build_name xsd_type.name

        Type.new name
      end

      def build_name qname
        Name.new qname.namespace, qname.name
      end
    end
  end
end
