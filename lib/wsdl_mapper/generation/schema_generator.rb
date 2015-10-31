require 'wsdl_mapper/naming/default_namer'

require 'wsdl_mapper/generation/result'
require 'wsdl_mapper/generation/default_formatter'
require 'wsdl_mapper/generation/default_class_generator'
require 'wsdl_mapper/generation/default_module_generator'
require 'wsdl_mapper/generation/null_ctr_generator'
require 'wsdl_mapper/generation/default_value_defaults_generator'
require 'wsdl_mapper/generation/default_enum_generator'
require 'wsdl_mapper/generation/default_wrapping_type_generator'
require 'wsdl_mapper/generation/default_value_generator'
require 'wsdl_mapper/generation/type_to_generate'

require 'wsdl_mapper/dom/complex_type'
require 'wsdl_mapper/dom/simple_type'

require 'wsdl_mapper/type_mapping'

module WsdlMapper
  module Generation
    class SchemaGenerator
      attr_reader :context, :namer

      attr_reader :class_generator, :module_generator, :ctr_generator, :enum_generator, :type_mapping, :value_defaults_generator, :value_generator, :wrapping_type_generator

      def initialize context,
          formatter_class: DefaultFormatter,
          namer: WsdlMapper::Naming::DefaultNamer.new,
          class_generator_factory: DefaultClassGenerator,
          module_generator_factory: DefaultModuleGenerator,
          ctr_generator_factory: NullCtrGenerator,
          enum_generator_factory: DefaultEnumGenerator,
          value_defaults_generator_factory: DefaultValueDefaultsGenerator,
          wrapping_type_generator_factory: DefaultWrappingTypeGenerator,
          type_mapping: WsdlMapper::TypeMapping::DEFAULT,
          value_generator: DefaultValueGenerator.new

        @formatter_class = formatter_class
        @context = context
        @namer = namer
        @class_generator = class_generator_factory.new self
        @module_generator = module_generator_factory.new self
        @ctr_generator = ctr_generator_factory.new self
        @enum_generator = enum_generator_factory.new self
        @value_defaults_generator = value_defaults_generator_factory.new self
        @wrapping_type_generator = wrapping_type_generator_factory.new self
        @type_mapping = type_mapping
        @value_generator = value_generator
      end

      def generate schema
        result = Result.new schema

        generate_complex_types schema, result
        generate_enumerations schema, result
        generate_restrictions schema, result

        result.module_tree.each do |module_node|
          @module_generator.generate module_node, result
        end

        result
      end

      def get_formatter io
        @formatter_class.new io
      end

      def get_ruby_type_name type
        if WsdlMapper::Dom::BuiltinType.builtin? type.name
          type_mapping.ruby_type type.name
        elsif WsdlMapper::Dom::SoapEncodingType.builtin? type.name
        else
          namer.get_type_name(type).name
        end
      end

      protected
      def generate_restrictions schema, result
        types = schema.each_type.select(&WsdlMapper::Dom::SimpleType).reject(&:enumeration?).to_a

        types_to_generate = types.map do |type|
          name = @namer.get_type_name type
          TypeToGenerate.new type, name
        end

        types_to_generate.each do |ttg|
          @wrapping_type_generator.generate ttg, result
          result.add_type ttg.name
        end
      end

      def generate_enumerations schema, result
        enum_types = schema.each_type.select(&WsdlMapper::Dom::SimpleType).select(&:enumeration?).to_a

        types_to_generate = enum_types.map do |type|
          name = @namer.get_type_name type

          TypeToGenerate.new type, name
        end

        types_to_generate.each do |ttg|
          @enum_generator.generate ttg, result
          result.add_type ttg.name
        end
      end

      def generate_complex_types schema, result
        complex_types = schema.each_type.select(&WsdlMapper::Dom::ComplexType).to_a

        types_to_generate = complex_types.map do |type|
          name = @namer.get_type_name type

          TypeToGenerate.new type, name
        end

        types_to_generate.each do |ttg|
          @class_generator.generate ttg, result
          result.add_type ttg.name
        end
      end
    end
  end
end
