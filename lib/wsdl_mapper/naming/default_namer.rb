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
        type_name = TypeName.new get_class_name(type), get_class_module_path(type), get_class_file_name(type), get_class_file_path(type)
        type_name.parent = make_parents @module_path
        type_name
      end

      def get_s8r_name type
        type_name = TypeName.new get_s8r_class_name(type), get_s8r_module_path(type), get_s8r_file_name(type), get_s8r_file_path(type)
        type_name.parent = make_parents @module_path
        type_name
      end

      def get_d10r_name type
        type_name = TypeName.new get_d10r_class_name(type), get_d10r_module_path(type), get_d10r_file_name(type), get_d10r_file_path(type)
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
      def get_class_module_path type
        @module_path
      end
      alias_method :get_s8r_module_path, :get_class_module_path
      alias_method :get_d10r_module_path, :get_class_module_path

      def get_class_file_path type
        get_file_path get_class_module_path type
      end
      alias_method :get_s8r_file_path, :get_class_file_path
      alias_method :get_d10r_file_path, :get_class_file_path

      def make_parents path
        return if path.empty?
        mod, path = path.last, path[0...-1]
        type_name = TypeName.new mod, path, get_file_name(mod), get_file_path(path)
        type_name.parent = make_parents path
        type_name
      end

      def get_d10r_file_name type
        underscore(type.name.name) + "_deserializer.rb"
      end

      def get_d10r_class_name type
        get_camelized_name(type.name.name) + "Deserializer"
      end

      def get_s8r_file_name type
        underscore(type.name.name) + "_serializer.rb"
      end

      def get_s8r_class_name type
        get_camelized_name(type.name.name) + "Serializer"
      end

      def get_class_name type
        get_camelized_name type.name.name
      end

      def get_class_file_name type
        get_file_name type.name.name
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

      def get_camelized_name name
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
