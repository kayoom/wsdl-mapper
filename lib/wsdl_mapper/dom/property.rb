require 'wsdl_mapper/dom/bounds'

module WsdlMapper
  module Dom
    class Property
      attr_reader :name, :type_name, :bounds, :sequence, :default, :fixed, :form
      attr_accessor :type, :containing_type
      attr_accessor :documentation

      def initialize name, type_name, bounds: Bounds.new, sequence: 0, default: nil, fixed: nil, form: nil
        @name, @type_name, @bounds, @sequence = name, type_name, bounds, sequence
        @documentation = Documentation.new
        @default = default
        @fixed = fixed
        @form = form
      end

      def default?
        !!@default
      end

      def fixed?
        !!@fixed
      end

      def array?
        @bounds.max.nil?
      end

      def single?
        @bounds.min == 1 && @bounds.max == 1
      end

      def optional?
        @bounds.min == 0 && @bounds.max == 1
      end

      def required?
        @bounds.min > 0
      end
    end
  end
end
