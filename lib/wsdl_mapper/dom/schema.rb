require 'wsdl_mapper/dom/builtin_type'
require 'wsdl_mapper/dom/soap_encoding_type'

module WsdlMapper
  module Dom
    class Schema
      attr_reader :types
      attr_accessor :target_namespace

      def initialize
        @types = {}
        @builtin_types = {}
        @soap_encoding_types = {}
      end

      def add_type type
        @types[type.name] = type
      end

      def get_type name
        if name.ns == BuiltinType::NAMESPACE
          @builtin_types[name] ||= BuiltinType.types[name]
        elsif name.ns == SoapEncodingType::NAMESPACE
          @soap_encoding_types[name] ||= SoapEncodingType.types[name]
        else
          @types[name]
        end
      end

      def each_type &block
        @types.values.each &block
      end

      def each_builtin_type &block
        @builtin_types.values.each &block
      end

      def each_soap_encoding_type &block
        @soap_encoding_types.values.each &block
      end
    end
  end
end
