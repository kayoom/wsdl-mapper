require 'wsdl_mapper/naming/default_namer'
require 'wsdl_mapper/generation/result'
require 'wsdl_mapper/generation/default_formatter'
require 'wsdl_mapper/generation/type_to_generate'
require 'wsdl_mapper/generation/default_module_generator'
require 'wsdl_mapper/dom/complex_type'
require 'wsdl_mapper/dom/simple_type'
require 'wsdl_mapper/generation/base'

module WsdlMapper
  module S8rGeneration
    class S8rGenerator < ::WsdlMapper::Generation::Base
      include WsdlMapper::Generation

      attr_reader :context

      def initialize context,
          namer: WsdlMapper::Naming::DefaultNamer.new,
          formatter_factory: DefaultFormatter,
          module_generator_factory: DefaultModuleGenerator,
          type_directory_name_template: 'S8rTypeDirectory',
          serializer_factory_name_template: 'SerializerFactory'

        @context = context
        @namer = namer
        @formatter_factory = formatter_factory
        @module_generator = module_generator_factory.new self
        @type_directory_name_template = type_directory_name_template
        @serializer_factory_name_template = serializer_factory_name_template
      end

      def generate schema
        result = Result.new schema

        generate_type_directory schema, result
        generate_serializer_factory schema, result

        schema.each_type do |type|
          generate_type type, result
        end

        result.module_tree.each do |module_node|
          @module_generator.generate module_node, result
        end

        result
      end

      def get_formatter io
        @formatter_factory.new io
      end

      protected
      def generate_serializer_factory schema, result
        @serializer_factory_name = @namer.get_support_name @serializer_factory_name_template
        file_name = @context.path_for @serializer_factory_name
        modules = @serializer_factory_name.parents.reverse
        default_namespace = schema.target_namespace ? ", default_namespace: #{schema.target_namespace.inspect}" : ''

        File.open file_name, 'w' do |io|
          f = get_formatter io
          f.requires 'wsdl_mapper/serializers/serializer_factory',
            @type_directory_name.require_path

          open_modules f, modules
          f.assignments [@serializer_factory_name.class_name, "::WsdlMapper::Serializers::SerializerFactory.new(#{@type_directory_name.name}#{default_namespace})"]
          close_modules f, modules
        end
      end

      def generate_type_directory schema, result
        @type_directory_name = @namer.get_support_name @type_directory_name_template
        file_name = @context.path_for @type_directory_name
        modules = @type_directory_name.parents.reverse

        File.open file_name, 'w' do |io|
          f = get_formatter io
          f.requires 'wsdl_mapper/serializers/type_directory'

          open_modules f, modules
          f.block "#{@type_directory_name.class_name} = ::WsdlMapper::Serializers::TypeDirectory.new", [] do
            schema.each_type do |type|
              generate_type_directory_entry f, type, result
            end
            schema.each_element do |element|
              generate_element_entry f, element, result
            end
          end
          close_modules f, modules
        end
      end

      def generate_element_entry f, element, result
        type_name = @namer.get_type_name get_type_name element.type
        type_class_name = type_name.name.inspect
        f.statement "register_element(#{type_class_name}, #{generate_name(element.name)})"
      end

      def generate_type_directory_entry f, type, result
        type_name = @namer.get_type_name get_type_name type
        s8r_name = @namer.get_s8r_name get_type_name type
        type_class_name = type_name.name.inspect
        require_path = s8r_name.require_path.inspect
        s8r_class_name = s8r_name.name.inspect
        f.statement "register_type(#{type_class_name}, #{require_path}, #{s8r_class_name})"
      end

      def generate_type type, result
        name = @namer.get_s8r_name get_type_name type
        file_name = @context.path_for name
        modules = name.parents.reverse

        File.open file_name, 'w' do |io|
          f = get_formatter io
          ttg = TypeToGenerate.new type, name
          f.requires @type_directory_name.require_path

          open_modules f, modules
          open_class f, ttg
          def_build_method f, ttg
          close_class f, ttg
          close_modules f, modules

          f.statement "#{@type_directory_name.name}.register_serializer(#{name.name.inspect}, #{name.name}.new)"
        end

        result.add_type name
        result.files << file_name
      end

      def def_simple_build_method_body f, ttg
        type_name = generate_name ttg.type.name
        f.block "x.simple(#{type_name}, name)", ['x'] do
          root_type = ttg.type.root.name.name
          f.statement "x.text_builtin(obj, #{root_type.inspect})"
        end
      end

      def def_complex_build_method_body f, ttg
        f.literal_array 'attributes', collect_attributes(ttg)
        type_name = generate_name ttg.type.name
        f.block "x.complex(#{type_name}, name, attributes)", ['x'] do
          if ttg.type.simple_content?
            write_content_statement f, ttg
          elsif ttg.type.soap_array?
            write_soap_array_statements f, ttg
          else
            write_property_statements f, ttg
          end
        end
      end

      def write_content_statement f, ttg
        content_name = @namer.get_content_name ttg.type
        type = ttg.type.base.name.name
        f.statement "x.text_builtin(obj.#{content_name.attr_name}, #{type.inspect})"
      end

      def write_property_statements f, ttg
        ttg.type.each_property do |prop|
          if prop.array?
            write_property_array_statement f, prop
          else
            write_property_statement f, prop
          end
        end
      end

      def collect_attributes ttg
        if ttg.type.soap_array?
          soap_array_attributes(ttg)
        else
          ttg.type.each_attribute.map do |attr|
            attr_name = generate_name attr.name
            accessor_name = @namer.get_attribute_name(attr).attr_name
            type = attr.type.root.name.name.inspect

            "[#{attr_name}, obj.#{accessor_name}, #{type}]"
          end
        end
      end

      def write_soap_array_statements f, ttg
        type_name = @namer.get_type_name get_type_name ttg.type
        item_name = generate_name WsdlMapper::Dom::Name.get(ttg.type.name.ns, @namer.get_soap_array_item_name(ttg.type))
        f.block 'obj.each', ['itm'] do
          f.statement "x.get(#{type_name.name.inspect}).build(x, itm, #{item_name})"
        end
      end

      def soap_array_attributes ttg
        # Use String#inspect to get the proper escaping, but cut off the last quotemark and append the array length
        name = ttg.type.soap_array_type_name.name.inspect[0..-2] + "[\#{obj.length}]\""
        [
          %<[[x.soap_enc, "arrayType"], #{name}, "string"]>
        ]
      end

      def write_property_array_statement f, prop
        name = "obj.#{@namer.get_property_name(prop).attr_name}.each"
        f.block name, ['itm'] do
          case prop.type
          when ::WsdlMapper::Dom::BuiltinType
            write_builtin_property_statement f, prop, 'itm'
          when ::WsdlMapper::Dom::ComplexType
            write_complex_property_statement f, prop, 'itm'
          when ::WsdlMapper::Dom::SimpleType
            write_simple_property_statement f, prop, 'itm'
          end
        end
      end

      def write_property_statement f, prop
        name = "obj.#{@namer.get_property_name(prop).attr_name}"
        case prop.type
        when ::WsdlMapper::Dom::BuiltinType
          write_builtin_property_statement f, prop, name
        when ::WsdlMapper::Dom::ComplexType
          write_complex_property_statement f, prop, name
        when ::WsdlMapper::Dom::SimpleType
          write_simple_property_statement f, prop, name
        end
      end

      def write_simple_property_statement f, prop, var_name
        element_name = generate_name prop.name
        type_name = @namer.get_type_name get_type_name prop.type
        f.statement "x.get(#{type_name.name.inspect}).build(x, #{var_name}, #{element_name})"
      end

      def write_complex_property_statement f, prop, var_name
        element_name = generate_name prop.name
        type_name = @namer.get_type_name get_type_name prop.type
        f.statement "x.get(#{type_name.name.inspect}).build(x, #{var_name}, #{element_name})"
      end

      def get_s8r_name prop
        if prop.type.name
          @namer.get_s8r_name prop.type
        else
          @namer.get_s8r_name @namer.get_inline_type prop
        end
      end

      def write_builtin_property_statement f, prop, name
        type = prop.type_name.name.inspect
        element_name = generate_name prop.name
        f.statement "x.value_builtin(#{element_name}, #{name}, #{type})"
      end

      def def_build_method f, ttg
        f.begin_def 'build', [:x, :obj, :name]
        f.statement 'return if obj.nil?'
        case ttg.type
        when ::WsdlMapper::Dom::ComplexType
          def_complex_build_method_body f, ttg
        when ::WsdlMapper::Dom::SimpleType
          def_simple_build_method_body f, ttg
        end
        f.end
      end

      def close_class f, ttg
        f.end
      end

      def open_class f, ttg
        f.begin_class ttg.name.class_name
      end

      def close_modules f, modules
        modules.each { f.end }
      end

      def open_modules f, modules
        modules.each do |mod|
          f.begin_module mod.module_name
        end
      end
    end
  end
end
