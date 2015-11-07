require 'wsdl_mapper/dom_generation/generator_base'

module WsdlMapper
  module DomGeneration
    class DefaultWrappingTypeGenerator < GeneratorBase

      def generate ttg, result
        file_name = @generator.context.path_for ttg.name

        modules = ttg.name.parents.reverse
        content_name = @generator.namer.get_content_name ttg.type

        File.open file_name, 'w' do |io|
          f = @generator.get_formatter io

          write_requires f, get_requires(ttg.type, result.schema)
          open_modules f, modules
          open_class f, ttg
          generate_accessor f, ttg, content_name
          generate_ctr f, ttg, result, content_name
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

      def generate_ctr f, ttg, result, content_name
        @generator.ctr_generator.generate_wrapping ttg, f, result, content_name.var_name, content_name.attr_name
      end

      def generate_accessor f, ttg, content_name
        f.attr_accessors content_name.attr_name
      end
    end
  end
end
