require 'wsdl_mapper/dom/type_base'
require 'wsdl_mapper/dom/shallow_schema'

module WsdlMapper
  module Dom
    class BuiltinType < TypeBase
      NAMESPACE = 'http://www.w3.org/2001/XMLSchema'.freeze

      extend ShallowSchema
      self.namespace = NAMESPACE

      def root
        self
      end
    end
  end
end
