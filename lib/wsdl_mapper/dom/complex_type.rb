require 'wsdl_mapper/dom/type_base'

module WsdlMapper
  module Dom
    class ComplexType < WsdlMapper::Dom::TypeBase
      attr_reader :properties, :attributes
      attr_accessor :base_type_name, :base, :simple_content, :soap_array, :soap_array_type, :soap_array_type_name,
        :containing_property, :containing_element

      def initialize(name)
        super
        @properties = {}
        @attributes = {}
        @simple_content = false
        @soap_array = false
        @base = nil
      end

      def add_attribute(attribute)
        attribute.containing_type = self
        @attributes[attribute.name] = attribute
      end

      def add_property(property)
        property.containing_type = self
        @properties[property.name] = property
      end

      def each_property(&block)
        properties.values.each(&block)
      end

      def each_property_with_bases(&block)
        [*bases, self].inject([]) do |arr, type|
          arr + type.each_property.to_a
        end.each(&block)
      end

      def each_attribute(&block)
        attributes.values.each(&block)
      end

      def simple_content?
        !!@simple_content
      end

      def soap_array?
        !!@soap_array
      end

      def root
        @base ? @base.root : self
      end

      def bases
        # TODO: test
        return [] unless @base

        [*@base.bases, @base]
      end
    end
  end
end
