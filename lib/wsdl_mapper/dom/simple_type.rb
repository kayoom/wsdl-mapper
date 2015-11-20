require 'wsdl_mapper/dom/type_base'
require 'wsdl_mapper/dom/enumeration_value'

module WsdlMapper
  module Dom
    class SimpleType < WsdlMapper::Dom::TypeBase
      attr_accessor :base, :base_type_name, :pattern, :min, :max, :containing_property, :containing_element, :min_inclusive, :max_inclusive, :total_digits, :fraction_digits
      attr_reader :enumeration_values

      def initialize name
        super
        @enumeration_values = []
      end

      def enumeration?
        @enumeration_values.any?
      end

      def root
        @base ? @base.root : self
      end

      def pattern?
        !!@pattern
      end
    end
  end
end
