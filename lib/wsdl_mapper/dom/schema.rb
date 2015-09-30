require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module Dom
    class Schema
      attr_reader :types
      attr_accessor :target_namespace

      def initialize
        @types = {}
      end

      def add_type type
        @types[type.name] = type
      end

      def get_type name
        if name.ns == BuiltinType::NAMESPACE
          BuiltinType.types[name]
        else
          @types[name]
        end
      end
    end
  end
end
