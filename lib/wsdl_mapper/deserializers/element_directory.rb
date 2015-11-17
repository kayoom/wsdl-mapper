require 'wsdl_mapper/dom/directory'
require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/deserializers/errors'

module WsdlMapper
  module Deserializers
    class ElementDirectory
      class ElementItem < Struct.new(:element_name, :type_name, :require_path, :class_name)
      end

      def initialize type_directory, &block
        @type_directory = type_directory
        @directory = WsdlMapper::Dom::Directory.new on_nil: Errors::UnknownElementError
        instance_exec &block
      end

      def register_element element_name, type_name, require_path, class_name
        element_name = WsdlMapper::Dom::Name.get *element_name
        type_name = WsdlMapper::Dom::Name.get *type_name
        @directory[element_name] = ElementItem.new element_name, type_name, require_path, class_name
      end

      def load element_name
        item = @directory[element_name]
        require item.require_path
      end

      def each_element &block
        @directory.each &block
      end

      def each_type &block
        @type_directory.each_type &block
      end
    end
  end
end
