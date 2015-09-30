require 'wsdl_mapper/dom/type_base'
require 'wsdl_mapper/dom/enumeration'

module WsdlMapper
  module Dom
    class SimpleType < WsdlMapper::Dom::TypeBase
      attr_accessor :base
      attr_reader :enumerations

      def initialize name
        super
        @enumerations = []
      end
    end
  end
end
