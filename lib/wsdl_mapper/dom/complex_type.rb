require 'wsdl_mapper/dom/type_base'

module WsdlMapper
  module Dom
    class ComplexType < WsdlMapper::Dom::TypeBase
      attr_reader :properties, :attributes
      attr_accessor :base_type_name, :base

      def initialize name
        super
        @properties = {}
        @attributes = {}
      end

      def add_attribute attribute
        attribute.containing_type = self
        @attributes[attribute.name] = attribute
      end

      def add_property property
        property.containing_type = self
        @properties[property.name] = property
      end

      def each_property &block
        properties.values.each &block
      end

      def each_attribute &block
        attributes.values.each &block
      end
    end
  end
end
