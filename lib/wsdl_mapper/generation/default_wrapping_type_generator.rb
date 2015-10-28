require 'wsdl_mapper/generation/generator_base'

module WsdlMapper
  module Generation
    class DefaultWrappingTypeGenerator < GeneratorBase

      def generate ttg, result
        file_name = @generator.context.path_for ttg.name

        modules = ttg.name.parents.reverse

        File.open file_name, 'w' do |io|
          f = @generator.get_formatter io

          write_requires f, get_requires(ttg.type, result.schema)
          open_modules f, modules
          open_class f, ttg
          generate_accessor f, ttg
          generate_ctr f, ttg, result
          close_class f, ttg
          close_modules f, modules
        end
        result.files << file_name
        self
      end

      protected
      def get_requires type, schema
        requires = []
        add_base_require requires, type, schema
        # TODO: collect requires from ctr generator
        requires.uniq
      end

      def open_class f, ttg
        f.begin_class ttg.name.class_name
      end

      def close_class f, ttg
        f.end
      end

      def generate_ctr f, ttg, result
        @generator.ctr_generator.generate_wrapping ttg, f, result, '@value', 'value'
      end

      def generate_accessor f, ttg
        f.attr_accessor 'value'
      end
    end
  end
end
