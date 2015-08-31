require 'wsdl_mapper/dom/type_base'

module WsdlMapper
  module Dom
    class BuiltinType < TypeBase
      NAMESPACE = "http://www.w3.org/2001/XMLSchema".freeze

      def self.types
        @types ||= Hash.new do |h, k|
          h[k] = build k
        end
      end

      def self.build name
        new name
      end
    end
  end
end
