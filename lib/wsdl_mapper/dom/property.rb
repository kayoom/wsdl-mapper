require 'wsdl_mapper/dom/bounds'

module WsdlMapper
  module Dom
    class Property
      attr_reader :name, :type_name, :bounds, :sequence
      attr_accessor :documentation

      def initialize name, type_name, bounds: Bounds.new, sequence: 0
        @name, @type_name, @bounds, @sequence = name, type_name, bounds, sequence
      end
    end
  end
end
