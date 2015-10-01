require 'wsdl_mapper/dom/bounds'

module WsdlMapper
  module Dom
    class Property
      attr_reader :name, :type_name, :bounds, :sequence, :default, :fixed, :form
      attr_accessor :documentation

      def initialize name, type_name, bounds: Bounds.new, sequence: 0, default: nil, fixed: nil, form: nil
        @name, @type_name, @bounds, @sequence = name, type_name, bounds, sequence
        @documentation = Documentation.new
        @default = default
        @fixed = fixed
        @form = form
      end
    end
  end
end
