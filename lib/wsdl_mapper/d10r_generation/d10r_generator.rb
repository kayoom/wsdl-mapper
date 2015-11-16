require 'wsdl_mapper/naming/default_namer'
require 'wsdl_mapper/generation/result'
require 'wsdl_mapper/generation/default_formatter'
require 'wsdl_mapper/generation/type_to_generate'
require 'wsdl_mapper/generation/default_module_generator'
require 'wsdl_mapper/dom/complex_type'
require 'wsdl_mapper/dom/simple_type'

module WsdlMapper
  module D10rGeneration
    class D10rGenerator
      include WsdlMapper::Generation

      attr_reader :context

      def initialize context,
          namer: WsdlMapper::Naming::DefaultNamer.new,
          formatter_factory: DefaultFormatter,
          module_generator_factory: DefaultModuleGenerator,
          deserializer_factory_name: 'DeserializerFactory'
        @context = context
        @namer = namer
        @formatter_factory = formatter_factory
        @module_generator = module_generator_factory.new self
        @deserializer_factory_name = deserializer_factory_name
      end

      def generate schema
        result = Result.new schema

        generate_factory result

        schema.each_type do |type|
          generate_type type, result
        end

        result.module_tree.each do |module_node|
          @module_generator.generate module_node, result
        end

        result
      end

      def generate_factory result
        @factory_name = @namer.get_support_name @deserializer_factory_name
        file_name = @context.path_for @factory_name
        modules = @factory_name.parents.reverse

        File.open file_name, 'w' do |io|
          f = get_formatter io
          f.requires "wsdl_mapper/deserializers/deserializer_factory"
          open_modules f, modules
          f.assignments [@factory_name.class_name, "::WsdlMapper::Deserializers::DeserializerFactory.new"]
          close_modules f, modules
        end

        result.add_type @factory_name
        result.files << file_name
      end

      def generate_type type, result
        case type
        when WsdlMapper::Dom::ComplexType
          generate_complex type, result
        end
      end

      def generate_complex type, result
        type_name = @namer.get_type_name type
        name = @namer.get_d10r_name type
        file_name = @context.path_for name
        modules = name.parents.reverse

        File.open file_name, 'w' do |io|
          f = get_formatter io
          f.requires @factory_name.require_path, type_name.require_path

          open_modules f, modules
          register_type f, name, type, type_name
          close_modules f, modules
        end

        result.add_type name
        result.files << file_name
      end

      def register_type f, name, type, type_name
        f.block "#{name.class_name} = #{@factory_name.name}.register(#{type.name.ns.inspect}, #{type.name.name.inspect}, #{type_name.name})", [] do
          register_attributes f, type
          register_properties f, type
        end
      end

      def register_attributes f, containing_type
        containing_type.each_attribute do |attr|
          acc_name = @namer.get_attribute_name attr
          type = attr.type.root
          name = attr.name
          f.statement "register_attr :#{acc_name.attr_name}, #{inspect_name(name)}, #{inspect_name(type.name)}"
        end
      end

      def register_properties f, containing_type
        containing_type.each_property do |prop|
          acc_name = @namer.get_property_name prop
          type = prop.type.is_a?(WsdlMapper::Dom::SimpleType) ? prop.type.root : prop.type
          f.statement "register_prop :#{acc_name.attr_name}, #{inspect_name(prop.name)}, #{inspect_name(type.name)}#{inspect_prop_options(prop)}"
        end
      end

      def get_formatter io
        @formatter_factory.new io
      end

      protected
      def inspect_prop_options prop
        opts = ""
        opts << ", array: true" if prop.array?
        opts
      end

      def inspect_name name
        "::WsdlMapper::Dom::Name.get(#{name.ns.inspect}, #{name.name.inspect})"
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
