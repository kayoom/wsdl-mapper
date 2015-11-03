require 'wsdl_mapper/naming/type_name'
require 'wsdl_mapper/naming/property_name'
require 'wsdl_mapper/naming/enumeration_value_name'
require 'wsdl_mapper/naming/inflector'

module WsdlMapper
  module Naming
    class DefaultNamer
      include Inflector

      def initialize module_path: [], content_attribute_name: 'content'
        @module_path = module_path
        @content_attribute_name = content_attribute_name
      end

      def get_type_name type
        type_name = TypeName.new get_class_name(type.name.name), @module_path, get_file_name(type.name.name), get_file_path(@module_path)
        type_name.parent = make_parents @module_path
        type_name
      end

      def get_s8r_name type
        type_name = TypeName.new get_s8r_class_name(type.name.name), @module_path, get_s8r_file_name(type.name.name), get_file_path(@module_path)
        type_name.parent = make_parents @module_path
        type_name
      end

      def get_property_name property
        PropertyName.new get_accessor_name(property.name.name), get_var_name(property.name.name)
      end

      def get_attribute_name attribute
        PropertyName.new get_accessor_name(attribute.name), get_var_name(attribute.name)
      end

      def get_enumeration_value_name type, enum_value
        EnumerationValueName.new get_constant_name(enum_value.value), get_key_name(enum_value.value)
      end

      def get_content_name type
        @content_name ||= PropertyName.new get_accessor_name(@content_attribute_name), get_var_name(@content_attribute_name)
      end

      protected
      def make_parents path
        return if path.empty?
        mod, path = path.last, path[0...-1]
        type_name = TypeName.new mod, path, get_file_name(mod), get_file_path(path)
        type_name.parent = make_parents path
        type_name
      end

      def get_s8r_file_name name
        underscore(name) + "_serializer.rb"
      end

      def get_s8r_class_name name
        get_class_name(name) + "Serializer"
      end

      def get_constant_name name
        get_key_name(name).upcase
      end

      def get_key_name name
        underscore sanitize name
      end

      def get_accessor_name name
        get_key_name name
      end

      def get_var_name name
        "@#{get_accessor_name(name)}"
      end

      def get_class_name name
        camelize name
      end

      def get_file_name name
        underscore(name) + ".rb"
      end

      def get_file_path path
        path.map do |m|
          underscore m
        end
      end

      def sanitize name
        if valid_symbol? name
          name
        else
          "value_#{name}"
        end
      end

      def valid_symbol? name
        name =~ /^[a-zA-Z]/
      end
    end
  end
end
