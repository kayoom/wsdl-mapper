require 'wsdl_mapper/naming/type_name'
require 'wsdl_mapper/naming/property_name'
require 'wsdl_mapper/naming/inflector'

module WsdlMapper
  module Naming
    class DefaultNamer
      include Inflector

      def initialize module_path: []
        @module_path = module_path
      end

      def get_type_name type
        TypeName.new get_class_name(type), @module_path, get_file_name(type), get_file_path
      end

      def get_property_name property
        PropertyName.new get_attribute_name(property), get_var_name(property)
      end

      private
      def get_attribute_name property
        underscore property.name.name
      end

      def get_var_name property
        "@#{get_attribute_name(property)}"
      end

      def get_class_name type
        camelize type.name.name
      end

      def get_file_name type
        underscore(type.name.name) + ".rb"
      end

      def get_file_path
        @module_path.map do |m|
          underscore m
        end
      end
    end
  end
end
