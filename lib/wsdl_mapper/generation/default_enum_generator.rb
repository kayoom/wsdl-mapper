require 'wsdl_mapper/generation/generator_base'

module WsdlMapper
  module Generation
    class DefaultEnumGenerator < GeneratorBase
      def initialize generator, base: '::String', values_const_name: 'Values'
        @generator = generator
        @base = base
        @values_const_name = values_const_name
      end

      def generate ttg, result
        file_name = @generator.context.path_for ttg.name

        modules = ttg.name.parents.reverse

        File.open file_name, 'w' do |io|
          f = @generator.get_formatter io
          values_to_generate = get_values_to_generate(ttg)

          open_modules f, modules
          open_class f, ttg
          generate_constant_assignments f, values_to_generate
          generate_values_array f, values_to_generate
          close_class f, ttg
          close_modules f, modules
        end
        result.files << file_name
        self
      end

      protected
      def close_class f, ttg
        f.end
      end

      def generate_values_array f, values_to_generate
        f.literal_array @values_const_name, values_to_generate.map { |vtg| vtg.name.constant_name }
      end

      def generate_constant_assignments f, values_to_generate
        values_to_generate.each do |vtg|
          f.statement value_constant_assignment vtg
        end
        f.after_constants
      end

      def get_values_to_generate ttg
        ttg.type.enumeration_values.map do |ev|
          name = @generator.namer.get_enumeration_value_name ttg.type, ev
          TypeToGenerate.new ev, name
        end
      end

      def open_class f, ttg
        f.begin_sub_class ttg.name.class_name, @base
      end

      def value_constant_assignment vtg
        "#{vtg.name.constant_name} = new(#{vtg.type.value.inspect}).freeze"
      end
    end
  end
end