require 'wsdl_mapper/dom/directory'
require 'wsdl_mapper/deserializers/errors'
require 'wsdl_mapper/deserializers/class_mapping'
require 'wsdl_mapper/deserializers/soap_array_mapping'

module WsdlMapper
  module Deserializers
    class TypeDirectory
      def initialize
        @types = WsdlMapper::Dom::Directory.new on_nil: Errors::UnknownTypeError
      end

      def register_type type_name, klass, simple: false, &block
        type_name = WsdlMapper::Dom::Name.get *type_name
        @types[type_name] = ClassMapping.new klass, simple: simple, &block
      end

      def register_soap_array type_name, klass, item_type_name
        type_name = WsdlMapper::Dom::Name.get *type_name
        @types[type_name] = SoapArrayMapping.new klass, type: item_type_name
      end

      def each_type &block
        @types.each &block
      end
    end
  end
end
