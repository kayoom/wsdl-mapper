require 'wsdl_mapper/generation/default_formatter'
require 'wsdl_mapper/naming/default_namer'
require 'wsdl_mapper/generation/result'

require 'wsdl_mapper/generation/class_generator'
require 'wsdl_mapper/generation/module_generator'
require 'wsdl_mapper/generation/no_ctr_generator'
require 'wsdl_mapper/generation/enum_generator'

require 'wsdl_mapper/dom/complex_type'
require 'wsdl_mapper/dom/simple_type'
require 'wsdl_mapper/generation/type_to_generate'

module WsdlMapper
  module Generation
    class SchemaGenerator
      attr_reader :context, :namer

      attr_reader :class_generator, :module_generator, :ctr_generator

      def initialize context,
          formatter_class: DefaultFormatter,
          namer: WsdlMapper::Naming::DefaultNamer.new,
          class_generator_factory: ClassGenerator,
          module_generator_factory: ModuleGenerator,
          ctr_generator_factory: NoCtrGenerator,
          enum_generator_factory: EnumGenerator

        @formatter_class = formatter_class
        @context = context
        @namer = namer
        @class_generator = class_generator_factory.new self
        @module_generator = module_generator_factory.new self
        @ctr_generator = ctr_generator_factory.new self
        @enum_generator = enum_generator_factory.new self
      end

      def generate schema
        result = Result.new

        generate_complex_types schema, result
        generate_enumerations schema, result

        result.module_tree.each do |module_node|
          @module_generator.generate module_node, result
        end

        result
      end

      def get_formatter io
        @formatter_class.new io
      end

      protected
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
