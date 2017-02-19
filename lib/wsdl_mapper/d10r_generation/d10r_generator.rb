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

      def initialize(context,
        skip_modules: false,
        namer: WsdlMapper::Naming::DefaultNamer.new,
        formatter_factory: DefaultFormatter,
        module_generator_factory: DefaultModuleGenerator)

        super(context)

        @namer = namer
        @formatter_factory = formatter_factory
        @module_generator = module_generator_factory.new self
        @type_directory_name = @namer.get_d10r_type_directory_name
        @element_directory_name = @namer.get_d10r_element_directory_name
        @deserializer_name = @namer.get_global_d10r_name
        @skip_modules = skip_modules
      end

      def generate(schema)
        result = Result.new schema: schema

        generate_type_directory schema, result

        schema.each_type do |type|
          generate_type type, result
        end

        unless @skip_modules
          result.module_tree.each do |module_node|
            @module_generator.generate module_node, result
          end
        end

        generate_element_directory schema, result
        generate_deserializer schema, result

        result
      end

      def get_formatter(io)
        @formatter_factory.new io
      end

      protected
      def generate_deserializer(schema, result)
        modules = @deserializer_name.parents.reverse.map &:module_name

        type_file_for @deserializer_name, result do |f|
          f.requires 'wsdl_mapper/deserializers/lazy_loading_deserializer',
            @element_directory_name.require_path
          f.in_modules modules do
            f.assignment @deserializer_name.class_name, "::WsdlMapper::Deserializers::LazyLoadingDeserializer.new(#{@element_directory_name.name})"
          end
        end
      end

      def generate_element_directory(schema, result)
        modules = get_module_names @element_directory_name

        type_file_for @element_directory_name, result do |f|
          f.requires @type_directory_name.require_path,
            'wsdl_mapper/deserializers/element_directory'
          f.in_modules modules do
            f.block_assignment @element_directory_name.class_name, "::WsdlMapper::Deserializers::ElementDirectory.new(#{@type_directory_name.name})", [] do
              register_elements f, schema, result
            end
          end
        end
      end

      def register_elements(f, schema, result)
        schema.each_element do |element|
          register_element f, element, result
        end
      end

      # @param [WsdlMapper::Generation::AbstractFormatter] f
      # @param [WsdlMapper::Dom::Element] element
      # @param [WsdlMapper::Generation::Result] result
      def register_element(f, element, result)
        element_name = generate_name element.name
        type_name = generate_name get_type_name(element.type).name
        d10r_name = @namer.get_d10r_name(element.type.name ? element.type : @namer.get_inline_type(element))
        require_path = d10r_name.require_path.inspect

        f.statement "register_element #{element_name}, #{type_name}, #{require_path}, #{d10r_name.name.inspect}"
      end

      def generate_type_directory(schema, result)
        modules = get_module_names @type_directory_name

        type_file_for @type_directory_name, result do |f|
          f.requires 'wsdl_mapper/deserializers/type_directory'
          f.in_modules modules do
            f.assignment @type_directory_name.class_name, '::WsdlMapper::Deserializers::TypeDirectory.new'
          end
        end
      end

      def generate_type(type, result)
        case type
        when WsdlMapper::Dom::ComplexType
          generate_complex type, result
        end
      end

      def generate_complex(type, result)
        type_name = @namer.get_type_name get_type_name type
        name = @namer.get_d10r_name get_type_name type
        modules = get_module_names name
        prop_requires = collect_property_requires(type.each_property)
        prop_requires += collect_property_requires(type.base.each_property) if has_base?(type)

        type_file_for name, result do |f|
          f.requires @type_directory_name.require_path, type_name.require_path
          f.requires(*prop_requires.uniq)

          f.in_modules modules do
            if type.soap_array?
              register_soap_array f, name, type, type_name
            else
              register_complex_type f, name, type, type_name
            end
          end
        end
      end

      def collect_property_requires(properties)
        properties.map do |prop|
          type = get_type_name(prop.type)
          next if WsdlMapper::Dom::BuiltinType.builtin?(type.name) || type.is_a?(WsdlMapper::Dom::SimpleType) || WsdlMapper::Dom::SoapEncodingType.builtin?(type.name)
          @namer.get_d10r_name(type).require_path
        end.compact
      end

      def register_soap_array(f, name, type, type_name)
        f.assignment name.class_name, "#{@type_directory_name.name}.register_soap_array(#{generate_name(type.name)}, #{type_name.name}, #{generate_name(type.soap_array_type_name)})"
      end

      def register_complex_type(f, name, type, type_name)
        simple = ", simple: #{generate_name(type.root.name)}" if type.simple_content?

        type_or_inline = get_type_name(type).name
        f.block_assignment name.class_name, "#{@type_directory_name.name}.register_type(#{generate_name(type_or_inline)}, #{type_name.name}#{simple})", [] do
          register_attributes f, type
          register_properties f, type
        end
      end

      def has_base?(type)
        WsdlMapper::Dom::ComplexType === type && type.base && WsdlMapper::Dom::ComplexType === type.base
      end

      def register_attributes(f, containing_type)
        if has_base? containing_type
          register_attributes f, containing_type.base
        end
        containing_type.each_attribute do |attr|
          acc_name = @namer.get_attribute_name attr
          type = attr.type.root
          name = attr.name
          f.call :register_attr, ":#{acc_name.attr_name}", generate_name(name), generate_name(type.name)
        end
      end

      def register_properties(f, containing_type)
        if has_base? containing_type
          register_properties f, containing_type.base
        end
        containing_type.each_property do |prop|
          acc_name = @namer.get_property_name prop
          type = prop.type.is_a?(WsdlMapper::Dom::SimpleType) ? prop.type.root : prop.type
          args = [":#{acc_name.attr_name}", generate_name(prop.name), generate_name(type.name)]
          args << 'array: true' if prop.array?
          f.call :register_prop, *args
        end
      end
    end
  end
end
