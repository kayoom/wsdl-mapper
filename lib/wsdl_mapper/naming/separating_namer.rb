require 'wsdl_mapper/naming/default_namer'

module WsdlMapper
  module Naming
    # Namer implementation which puts the generated classes into different namespaces,
    # according to their funtion: `Types` for types, `S8r` for serializers and `D10r`
    # for deserializers.
    class SeparatingNamer < DefaultNamer

      # @param [Array<String>] module_path Root module path, e.g. to generate classes in
      #                                    `::MyApi::Types`, specify `['MyApi']` as root module path
      # @param [String] content_attribute_name Sets name of the attribute generated for direct content
      #                                        of types. You can change it, if this clashes with attributes
      #                                        in your schema.
      # @param [Array<String>] types_module Where to generate types
      # @param [Array<String>] s8r_module Where to genereate serializers
      # @param [Array<String>] d10r_module Where to generate deserializers
      def initialize(module_path: [],
          content_attribute_name: 'content',
          soap_array_item_name: 'item',
          types_module: ['Types'],
          s8r_module: ['S8r'],
          d10r_module: ['D10r'])

        super(module_path: module_path,
            content_attribute_name: content_attribute_name,
            soap_array_item_name: soap_array_item_name)

        @types_module = types_module
        @s8r_module = s8r_module
        @d10r_module = d10r_module
      end

      protected
      def get_s8r_module_path(type)
        @module_path + @s8r_module
      end

      def get_class_module_path(type)
        @module_path + @types_module
      end

      def get_d10r_module_path(type)
        @module_path + @d10r_module
      end

      def get_class_file_path(type)
        get_file_path get_class_module_path type
      end

      def get_s8r_file_path(type)
        get_file_path get_s8r_module_path type
      end

      def get_d10r_file_path(type)
        get_file_path get_d10r_module_path type
      end

      def get_d10r_file_name(type)
        underscore(type.name.name) + '_deserializer.rb'
      end

      def get_d10r_class_name(type)
        get_camelized_name(type.name.name) + 'Deserializer'
      end

      def get_s8r_file_name(type)
        underscore(type.name.name) + '_serializer.rb'
      end

      def get_s8r_class_name(type)
        get_camelized_name(type.name.name) + 'Serializer'
      end

      def get_class_name(type)
        get_camelized_name type.name.name
      end

      def get_class_file_name(type)
        get_file_name type.name.name
      end

      def get_constant_name(name)
        get_key_name(name).upcase
      end

      def get_key_name(name)
        underscore sanitize name
      end

      def get_accessor_name(name)
        get_key_name name
      end

      def get_var_name(name)
        "@#{get_accessor_name(name)}"
      end

      def get_camelized_name(name)
        camelize name
      end

      def get_file_name(name)
        underscore(name) + '.rb'
      end

      def get_file_path(path)
        path.map do |m|
          underscore m
        end
      end

      def sanitize(name)
        if valid_symbol? name
          name
        else
          "value_#{name}"
        end
      end
    end
  end
end
