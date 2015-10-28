require 'wsdl_mapper/generation/generator_base'
require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module Generation
    class DefaultClassGenerator < GeneratorBase
      def generate ttg, result
        file_name = @generator.context.path_for ttg.name
        property_names = ttg.type.each_property.map { |p| @generator.namer.get_property_name p }
        attribute_names = ttg.type.each_attribute.map { |a| @generator.namer.get_attribute_name a }
        # TODO: attributes for attributes
        modules = ttg.name.parents.reverse

        File.open file_name, 'w' do |io|
          f = @generator.get_formatter io

          write_requires f, get_requires(ttg.type, result.schema)
          open_modules f, modules
          open_class f, ttg
          generate_property_attributes f, property_names
          generate_attribute_attributes f, attribute_names
          generate_ctr f, ttg, result
          close_class f, ttg
          close_modules f, modules
        end
        result.files << file_name
        self
      end

      protected
      def generate_attribute_attributes f, attribute_names
        return unless attribute_names.any?

        f.attr_accessor *attribute_names.map(&:attr_name)
      end

      def generate_property_attributes f, property_names
        return unless property_names.any?

        # TODO: readonly?
        f.attr_accessor *property_names.map(&:attr_name)
      end

      def generate_ctr f, ttg, result
        @generator.ctr_generator.generate ttg, f, result
      end

      def get_requires type, schema
        requires = []
        add_base_require requires, type, schema
        type.each_property do |prop|
          add_type_require requires, prop.type_name, schema
        end
        # TODO: collect requires from ctr generator
        requires.uniq
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
