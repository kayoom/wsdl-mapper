require 'wsdl_mapper/dom/type_base'

module WsdlMapper
  module Dom
    class ComplexType < WsdlMapper::Dom::TypeBase
      attr_reader :properties, :attributes
      attr_accessor :base

      def initialize name
        super
        @properties = {}
        @attributes = {}
      end

      def add_attribute attribute
        @attributes[attribute.name] = attribute
      end

      def add_property property
        @properties[property.name] = property
      end
    end
  end
end
