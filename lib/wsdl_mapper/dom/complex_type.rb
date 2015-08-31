require 'wsdl_mapper/dom/type_base'

module WsdlMapper
  module Dom
    class ComplexType < WsdlMapper::Dom::TypeBase
      attr_reader :properties

      def initialize name
        super
        @properties = {}
      end

      def add_property property
        @properties[property.name] = property
      end
    end
  end
end
