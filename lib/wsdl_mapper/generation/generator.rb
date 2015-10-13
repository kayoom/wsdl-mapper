require 'wsdl_mapper/generation/default_formatter'
require 'wsdl_mapper/naming/default_namer'
require 'wsdl_mapper/generation/result'

require 'wsdl_mapper/generation/class_generator'
require 'wsdl_mapper/generation/module_generator'

require 'wsdl_mapper/dom/complex_type'
require 'wsdl_mapper/generation/type_to_generate'

module WsdlMapper
  module Generation
    class Generator
      attr_reader :context, :namer

      def initialize context,
          formatter_class: DefaultFormatter,
          namer: WsdlMapper::Naming::DefaultNamer.new,
          class_generator_class: ClassGenerator,
          module_generator_class: ModuleGenerator

        @formatter_class = formatter_class
        @context = context
        @namer = namer
        @class_generator = class_generator_class.new self
        @module_generator = module_generator_class.new self
      end

      def generate schema
        result = Result.new

        complex_types = schema.each_type.select(&WsdlMapper::Dom::ComplexType).to_a

        types_to_generate = complex_types.map do |type|
          name = @namer.get_type_name type

          TypeToGenerate.new type, name
        end

        types_to_generate.each do |ttg|
          @class_generator.generate ttg, result
          result.add_type ttg.name
        end

        result.module_tree.each do |module_node|
          @module_generator.generate module_node, result
        end

        result
      end

      def get_formatter io
        @formatter_class.new io
      end
    end
  end
end
