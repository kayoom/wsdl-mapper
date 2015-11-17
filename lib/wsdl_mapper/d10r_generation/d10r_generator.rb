require 'wsdl_mapper/naming/default_namer'
require 'wsdl_mapper/generation/result'
require 'wsdl_mapper/generation/default_formatter'
require 'wsdl_mapper/generation/type_to_generate'
require 'wsdl_mapper/generation/default_module_generator'
require 'wsdl_mapper/dom/complex_type'
require 'wsdl_mapper/dom/simple_type'
require 'wsdl_mapper/generation/base'

module WsdlMapper
  module D10rGeneration
    class D10rGenerator < WsdlMapper::Generation::Base
      include WsdlMapper::Generation

      attr_reader :context

      def initialize context,
          namer: WsdlMapper::Naming::DefaultNamer.new,
          formatter_factory: DefaultFormatter,
          module_generator_factory: DefaultModuleGenerator,
          type_directory_name_template: 'TypeDirectory',
          element_directory_name_template: 'ElementDirectory'
        @context = context
        @namer = namer
        @formatter_factory = formatter_factory
        @module_generator = module_generator_factory.new self
        @type_directory_name_template = type_directory_name_template
        @element_directory_name_template = element_directory_name_template
      end

      def generate schema
        result = Result.new schema

        generate_type_directory schema, result

        schema.each_type do |type|
          generate_type type, result
        end

        result.module_tree.each do |module_node|
          @module_generator.generate module_node, result
        end

        generate_element_directory schema, result

        result
      end

      def generate_element_directory schema, result
        @element_directory_name = @namer.get_support_name @element_directory_name_template
        file_name = @context.path_for @element_directory_name
        modules = @element_directory_name.parents.reverse

        File.open file_name, 'w' do |io|
          f = get_formatter io
          f.requires 'wsdl_mapper/deserializers/type_directory',
            'wsdl_mapper/deserializers/element_directory'
          open_modules f, modules
          f.block "#{@element_directory_name.class_name} = ::WsdlMapper::Deserializers::ElementDirectory.new(#{@type_directory_name.name})", [] do
            register_elements f, schema, result
          end
          close_modules f, modules
        end

        result.add_type @element_directory_name
        result.files << file_name
      end

      def register_elements f, schema, result
        schema.each_element do |element|
          register_element f, element, result
        end
      end

      # @param [WsdlMapper::Generation::AbstractFormatter] f
      # @param [WsdlMapper::Dom::Element] element
      # @param [WsdlMapper::Generation::Result] result
      def register_element f, element, result
        element_name = generate_name element.name
        type_name = generate_name element.type_name
        d10r_name = @namer.get_d10r_name(element.type.name ? element.type : @namer.get_inline_type(element))
        require_path = d10r_name.require_path.inspect
        f.statement "register_element #{element_name}, #{type_name}, #{require_path}, #{d10r_name.name.inspect}"
      end

      def generate_type_directory schema, result
        @type_directory_name = @namer.get_support_name @type_directory_name_template
        file_name = @context.path_for @type_directory_name
        modules = @type_directory_name.parents.reverse

        File.open file_name, 'w' do |io|
          f = get_formatter io
          f.requires 'wsdl_mapper/deserializers/type_directory'
          open_modules f, modules
          f.assignments [@type_directory_name.class_name, '::WsdlMapper::Deserializers::TypeDirectory.new']
          close_modules f, modules
        end

        result.add_type @type_directory_name
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
          f.requires @type_directory_name.require_path, type_name.require_path

          open_modules f, modules
          if type.soap_array?
            register_soap_array f, name, type, type_name
          else
            register_complex_type f, name, type, type_name
          end
          close_modules f, modules
        end

        result.add_type name
        result.files << file_name
      end

      def register_soap_array f, name, type, type_name
        f.assignments [name.class_name, "#{@type_directory_name.name}.register_soap_array(#{generate_name(type.name)}, #{type_name.name})"]
      end

      def register_complex_type f, name, type, type_name
        f.block "#{name.class_name} = #{@type_directory_name.name}.register_type(#{generate_name(type.name)}, #{type_name.name})", [] do
          register_attributes f, type
          register_properties f, type
        end
      end

      def register_attributes f, containing_type
        containing_type.each_attribute do |attr|
          acc_name = @namer.get_attribute_name attr
          type = attr.type.root
          name = attr.name
          f.statement "register_attr :#{acc_name.attr_name}, #{generate_name(name)}, #{generate_name(type.name)}"
        end
      end

      def register_properties f, containing_type
        containing_type.each_property do |prop|
          acc_name = @namer.get_property_name prop
          type = prop.type.is_a?(WsdlMapper::Dom::SimpleType) ? prop.type.root : prop.type
          f.statement "register_prop :#{acc_name.attr_name}, #{generate_name(prop.name)}, #{generate_name(type.name)}#{inspect_prop_options(prop)}"
        end
      end

      def get_formatter io
        @formatter_factory.new io
      end

      protected
      def inspect_prop_options prop
        opts = ''
        opts << ', array: true' if prop.array?
        opts
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
