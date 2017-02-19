require 'wsdl_mapper/dom/schema'
require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/dom/complex_type'
require 'wsdl_mapper/dom/property'
require 'wsdl_mapper/dom/attribute'
require 'wsdl_mapper/dom/bounds'


module WsdlMapper
  module Dom
    class Builder
      def initialize(xsd_file)
        @xsd_file = xsd_file
      end

      def build
        schema = Schema.new

        @xsd_file.complex_types.each do |xsd_type|
          schema.add_type build_type(schema, xsd_type)
        end

        schema
      end

      def build_type(schema, xsd_type)
        name = build_name xsd_type.name

        type = ComplexType.new name

        xsd_type.elements.each do |element|
          property = build_property schema, element
          type.add_property property
        end

        type
      end

      def build_property(_schema, xsd_element)
        name = build_name xsd_element.name
        type_name = build_name xsd_element.type

        sequence = get_sequence xsd_element
        bounds = get_bounds xsd_element

        Property.new name, type_name, sequence: sequence, bounds: bounds
      end

      def build_name(qname)
        Name.get qname.namespace, qname.name
      end

      def get_bounds(xsd_element)
        parent_bounds = get_parent_bounds xsd_element.parent
        # bounds = get_attribute_bounds xsd_element

        parent_bounds #.override bounds
      end

      def get_parent_bounds(xsd_element)
        case xsd_element
        when WSDL::XMLSchema::Sequence
          Bounds.new min: 1, max: 1
        else
          Bounds.new
        end
      end

      def get_sequence(xsd_element)
        parent = xsd_element.parent
        return 0 unless parent.is_a? WSDL::XMLSchema::Sequence

        parent.elements.find_index xsd_element
      end
    end
  end
end
