require 'wsdl_mapper/dom/type_base'

module WsdlMapper
  module Dom
    class Enumeration < TypeBase
      def value
        name
      end

      def value= value
        self.name = value
      end
    end
  end
end
