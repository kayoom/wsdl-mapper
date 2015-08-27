require 'wsdl_mapper/dom/bounds'

module WsdlMapper
  module Dom
    class Property
      attr_reader :name, :type, :bounds, :sequence

      def initialize name, type, bounds: Bounds.new, sequence: 0
        @name, @type, @bounds, @sequence = name, type, bounds, sequence
      end
    end
  end
end
