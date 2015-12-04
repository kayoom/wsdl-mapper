require 'wsdl_mapper/dom/documentation'

module WsdlMapper
  module Dom
    class Element
      attr_reader :name
      attr_accessor :type_name, :type, :documentation

      def initialize(name)
        @name = name
        @documentation = Documentation.new
      end
    end
  end
end
