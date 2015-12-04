require 'wsdl_mapper/dom_generation/generator_base'

module WsdlMapper
  module DomGeneration
    class DefaultWrappingTypeGenerator < GeneratorBase

      def generate(ttg, result)
        modules = get_module_names ttg.name
        content_name = @generator.namer.get_content_name ttg.type

        type_file_for ttg.name, result do |f|
          write_requires f, get_requires(ttg.type, result.schema)
          f.in_modules modules do
            in_class f, ttg do
              generate_accessor f, ttg, content_name
              generate_ctr f, ttg, result, content_name
            end
          end
        end
        self
      end

      protected
      def get_requires(type, schema)
        requires = []
        add_base_require requires, type, schema
        # TODO: collect requires from ctr generator
        requires.uniq
      end

      def in_class(f, ttg, &block)
        f.in_class ttg.name.class_name, &block
      end

      def generate_ctr(f, ttg, result, content_name)
        @generator.ctr_generator.generate_wrapping ttg, f, result, content_name.var_name, content_name.attr_name
      end

      def generate_accessor(f, ttg, content_name)
        f.attr_accessors content_name.attr_name
      end
    end
  end
end
