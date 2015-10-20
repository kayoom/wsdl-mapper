require 'wsdl_mapper/generation/generator_base'

module WsdlMapper
  module Generation
    class ClassGenerator < GeneratorBase
      def generate ttg, result
        file_name = @generator.context.path_for ttg.name
        property_names = ttg.type.each_property.map { |p| @generator.namer.get_property_name p }
        modules = ttg.name.parents.reverse

        File.open file_name, 'w' do |io|
          f = @generator.get_formatter io

          write_requires f, get_requires(ttg.type)
          open_modules f, modules
          open_class f, ttg
          generate_attributes f, property_names
          generate_ctr f, ttg, result
          close_class f, ttg
          close_modules f, modules
        end
        result.files << file_name
        self
      end

      protected
      def generate_attributes f, property_names
        f.attr_accessor *property_names.map(&:attr_name)
      end

      def generate_ctr f, ttg, result
        @generator.ctr_generator.generate ttg, f, result
      end

      def get_requires type
        return [] unless type.base

        base_name = @generator.namer.get_type_name type.base
        [base_name.require_path]
      end

      def close_class f, ttg
        f.end
      end

      def open_class f, ttg
        if ttg.type.base
          base_name = @generator.namer.get_type_name ttg.type.base
          f.begin_sub_class ttg.name.class_name, base_name.name
        else
          f.begin_class ttg.name.class_name
        end
      end
    end
  end
end
