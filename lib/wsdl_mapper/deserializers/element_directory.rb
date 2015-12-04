require 'wsdl_mapper/dom/directory'
require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/deserializers/errors'

module WsdlMapper
  module Deserializers
    class ElementDirectory
      class ElementItem < Struct.new(:element_name, :type_name, :require_path, :class_name)
        attr_accessor :loaded
      end

      def initialize type_directory, *base, &block
        @type_directory = type_directory
        @directory = WsdlMapper::Dom::Directory.new on_nil: Errors::UnknownElementError
        @base = base
        instance_exec &block if block_given?
      end

      def register_element element_name, type_name, require_path, class_name
        element_name = WsdlMapper::Dom::Name.get *element_name
        type_name = WsdlMapper::Dom::Name.get *type_name
        @directory[element_name] = ElementItem.new element_name, type_name, require_path, class_name
      end

      def knows? element_name
        @directory.has_key?(element_name) || @base.any? { |b| b.knows? element_name }
      end

      def load element_name
        if @directory.has_key? element_name
          item = @directory[element_name]
          if item.loaded
            false
          else
            require item.require_path
            item.loaded = true
            true
          end
        else
          base = @base.find { |b| b.knows? element_name }
          unless base
            raise Errors::UnknownElementError.new element_name
          end
          base.load element_name
        end
      end

      def each_element &block
        if block_given?
          @base.each do |base|
            base.each_element &block
          end
          @directory.each &block
        else
          types = @base.inject([]) { |sum, b| sum + b.each_element.to_a }
          types + @directory.each.to_a
        end
      end

      def each_type &block
        @type_directory.each_type &block
      end
    end
  end
end
