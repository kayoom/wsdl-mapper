require 'wsdl_mapper/dom_generation/generator_base'
require 'wsdl_mapper/generation/default_formatter'

module WsdlMapper
  module DomGeneration
    class DefaultEnumGenerator < GeneratorBase
      include WsdlMapper::Generation

      def initialize(generator, base: '::String', values_const_name: 'Values')
        @generator = generator
        @context = generator.context
        @base = base
        @values_const_name = values_const_name
      end

      def generate(ttg, result)
        modules = get_module_names ttg.name
        values_to_generate = get_values_to_generate(ttg)

        type_file_for ttg.name, result do |f|
          f.in_modules modules do
            in_class f, ttg do
              generate_constant_assignments f, values_to_generate
              generate_values_array f, values_to_generate
            end
          end
        end
        self
      end

      protected
      def generate_values_array(f, values_to_generate)
        f.literal_array @values_const_name, values_to_generate.map { |vtg| vtg.name.constant_name }
      end

      def generate_constant_assignments(f, values_to_generate)
        values_to_generate.each do |vtg|
          f.statement value_constant_assignment vtg
        end
        f.after_constants
      end

      def get_values_to_generate(ttg)
        ttg.type.enumeration_values.uniq(&:value).map do |ev|
          name = @generator.namer.get_enumeration_value_name ttg.type, ev
          TypeToGenerate.new ev, name
        end
      end

      def in_class(f, ttg, &block)
        f.in_sub_class ttg.name.class_name, @base, &block
      end

      def value_constant_assignment(vtg)
        "#{vtg.name.constant_name} = new(#{vtg.type.value.inspect}).freeze"
      end
    end
  end
end
