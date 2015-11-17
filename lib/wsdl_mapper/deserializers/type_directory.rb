require 'wsdl_mapper/dom/directory'
require 'wsdl_mapper/deserializers/errors'
require 'wsdl_mapper/deserializers/class_mapping'

module WsdlMapper
  module Deserializers
    class TypeDirectory
      def initialize
        @types = WsdlMapper::Dom::Directory.new on_nil: Errors::UnknownTypeError
      end

      def register_type type_name, klass, &block
        type_name = WsdlMapper::Dom::Name.get *type_name
        @types[type_name] = ClassMapping.new klass, &block
      end

      def each_type &block
        @types.each &block
      end
    end
  end
end
