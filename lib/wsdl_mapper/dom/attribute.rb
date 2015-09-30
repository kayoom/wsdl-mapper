require 'wsdl_mapper/dom/bounds'

module WsdlMapper
  module Dom
    class Attribute
      attr_reader :name, :type_name
      attr_accessor :documentation

      def initialize name, type_name
        @name, @type_name = name, type_name
        @documentation = Documentation.new
      end
    end
  end
end
