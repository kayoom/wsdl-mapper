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

      def initialize(context,
        skip_modules: false,
        namer: WsdlMapper::Naming::DefaultNamer.new,
        formatter_factory: DefaultFormatter,
        module_generator_factory: DefaultModuleGenerator)

        super(context)

        @namer = namer
        @formatter_factory = formatter_factory
        @module_generator = module_generator_factory.new self
        @type_directory_name = namer.get_s8r_type_directory_name
        @serializer_name = namer.get_global_s8r_name
        @skip_modules = skip_modules
      end

      def generate(schema)
        result = Result.new schema: schema

        generate_type_directory schema, result
        generate_serializer_factory schema, result

        schema.each_type do |type|
          generate_type type, result
        end

        unless @skip_modules
          result.module_tree.each do |module_node|
            @module_generator.generate module_node, result
          end
        end

        result
      end

      protected
      def generate_serializer_factory(schema, result)
        modules = get_module_names @serializer_name

        file_for @serializer_name, result do |f|
          f.requires 'wsdl_mapper/serializers/serializer_factory',
            @type_directory_name.require_path

          f.in_modules modules do
            args = [@type_directory_name.name]
            args << "default_namespace: #{schema.target_namespace.inspect}" if schema.target_namespace
            f.assignment @serializer_name.class_name, "::WsdlMapper::Serializers::SerializerFactory.new(#{args * ', '})"
          end
        end
      end

      def generate_type_directory(schema, result)
        modules = get_module_names @type_directory_name

        file_for @type_directory_name, result do |f|
          f.requires 'wsdl_mapper/serializers/type_directory'

          f.in_modules modules do
            f.block_assignment @type_directory_name.class_name, '::WsdlMapper::Serializers::TypeDirectory.new', [] do
              schema.each_type do |type|
                generate_type_directory_entry f, type, result
              end
              schema.each_element do |element|
                generate_element_entry f, element, result
              end
            end
          end
        end
      end

      def generate_element_entry(f, element, result)
        type_name = @namer.get_type_name get_type_name element.type
        type_class_name = type_name.name.inspect

        f.call :register_element, type_class_name, generate_name(element.name)
      end

      def generate_type_directory_entry(f, type, result)
        type_name = @namer.get_type_name get_type_name type
        s8r_name = @namer.get_s8r_name get_type_name type
        type_class_name = type_name.name.inspect
        require_path = s8r_name.require_path.inspect
        s8r_class_name = s8r_name.name.inspect

        f.call :register_type, type_class_name, require_path, s8r_class_name
      end

      def generate_type(type, result)
        name = @namer.get_s8r_name get_type_name type
        modules = get_module_names name

        type_file_for name, result do |f|
          ttg = TypeToGenerate.new type, name
          f.requires @type_directory_name.require_path

          f.in_modules modules do
            f.in_class ttg.name.class_name do
              def_build_method f, ttg
            end
          end

          f.call "#{@type_directory_name.name}.register_serializer", name.name.inspect, "#{name.name}.new"
        end
      end

      def def_simple_build_method_body(f, ttg)
        type_name = generate_name ttg.type.name
        f.block "x.simple(#{type_name}, name)", ['x'] do
          root_type = ttg.type.root.name.name
          f.call 'x.text_builtin', 'obj', root_type.inspect
        end
      end

      def def_complex_build_method_body(f, ttg)
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

      def write_content_statement(f, ttg)
        content_name = @namer.get_content_name ttg.type
        type = ttg.type.base.name.name
        f.call 'x.text_builtin', "obj.#{content_name.attr_name}", type.inspect
      end

      def write_property_statements(f, ttg)
        types = ttg.type.bases << ttg.type
        types.each do |type|
          type.each_property do |prop|
            if prop.array?
              write_property_array_statement f, prop
            else
              write_property_statement f, prop
            end
          end
        end
      end

      def collect_attributes(ttg)
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

      def write_soap_array_statements(f, ttg)
        type_name = @namer.get_type_name get_type_name ttg.type
        item_name = generate_name WsdlMapper::Dom::Name.get(ttg.type.name.ns, @namer.get_soap_array_item_name(ttg.type))
        f.block 'obj.each', ['itm'] do
          write_soap_array_item_statement(f, ttg.type, item_name)
        end
      end

      def write_soap_array_item_statement(f, type, item_name)
        case type.soap_array_type
        when ::WsdlMapper::Dom::BuiltinType
          write_value_builtin_statement f, item_name, 'itm', type.soap_array_type_name.name.inspect
        when ::WsdlMapper::Dom::ComplexType
          type_name = @namer.get_type_name type.soap_array_type
          f.statement "x.get(#{type_name.name.inspect}).build(x, itm, #{item_name})"
        when ::WsdlMapper::Dom::SimpleType
          type_name = @namer.get_type_name type.soap_array_type
          f.statement "x.get(#{type_name.name.inspect}).build(x, itm, #{item_name})"
        end
      end

      def soap_array_attributes(ttg)
        # Use String#inspect to get the proper escaping, but cut off the last quotemark and append the array length
        ns = ttg.type.soap_array_type_name.ns.inspect
        name = ttg.type.soap_array_type_name.name.inspect[0..-2] + "[\#{obj.length}]\""
        # TODO: what about its namespace?
        [
          %<[[x.soap_enc, "arrayType"], [#{ns}, #{name}], "string"]>
        ]
      end

      def write_property_array_statement(f, prop)
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

      def write_property_statement(f, prop)
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

      def write_simple_property_statement(f, prop, var_name)
        element_name = generate_name prop.name
        type_name = @namer.get_type_name get_type_name prop.type
        f.statement "x.get(#{type_name.name.inspect}).build(x, #{var_name}, #{element_name})"
      end

      def write_complex_property_statement(f, prop, var_name)
        element_name = generate_name prop.name
        type_name = @namer.get_type_name get_type_name prop.type
        f.statement "x.get(#{type_name.name.inspect}).build(x, #{var_name}, #{element_name})"
      end

      def get_s8r_name(prop)
        if prop.type.name
          @namer.get_s8r_name prop.type
        else
          @namer.get_s8r_name @namer.get_inline_type prop
        end
      end

      def write_builtin_property_statement(f, prop, name)
        type = prop.type_name.name.inspect
        element_name = generate_name prop.name
        write_value_builtin_statement(f, element_name, name, type)
      end

      def write_value_builtin_statement(f, element_name, name, type)
        f.statement "x.value_builtin(#{element_name}, #{name}, #{type})"
      end

      def def_build_method(f, ttg)
        f.in_def 'build', :x, :obj, :name do
          f.statement 'return if obj.nil?'
          case ttg.type
          when ::WsdlMapper::Dom::ComplexType
            def_complex_build_method_body f, ttg
          when ::WsdlMapper::Dom::SimpleType
            def_simple_build_method_body f, ttg
          end
        end
      end
    end
  end
end
