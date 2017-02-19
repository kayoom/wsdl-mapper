require 'wsdl_mapper/dom_generation/generator_base'
require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module DomGeneration
    class DefaultClassGenerator < GeneratorBase
      def generate(ttg, result)
        modules = get_module_names ttg.name

        type_file_for ttg.name, result do |f|
          write_requires f, get_requires(ttg.type, result.schema)
          f.in_modules modules do
            in_class f, ttg do
              generate_content_attribute f, ttg if ttg.type.simple_content?
              generate_property_attributes f, ttg.type.each_property
              generate_attribute_attributes f, ttg.type.each_attribute
              generate_ctr f, ttg, result
            end
          end
        end
        self
      end

      protected
      def generate_content_attribute(f, ttg)
        name = @generator.namer.get_content_name(ttg.type)
        f.attr_accessors name.attr_name
      end

      def generate_attribute_attributes(f, attributes)
        return unless attributes.any?
        attribute_names = attributes.map { |a| @generator.namer.get_attribute_name a }

        f.attr_accessors(*attribute_names.map(&:attr_name))
      end

      def generate_property_attributes(f, properties)
        return unless properties.any?
        property_names = properties.map { |p| @generator.namer.get_property_name p }

        # TODO: readonly?
        f.attr_accessors(*property_names.map(&:attr_name))
      end

      def generate_ctr(f, ttg, result)
        if ttg.type.simple_content?
          @generator.ctr_generator.generate_simple ttg, f, result
        else
          @generator.ctr_generator.generate ttg, f, result
        end
      end

      def get_requires(type, schema)
        requires = []
        add_base_require requires, type, schema
        type.each_property do |prop|
          add_prop_require requires, prop, schema
        end
        # TODO: collect requires from ctr generator?
        requires.uniq
      end

      def in_class(f, ttg, &block)
        if base_name = get_base_name(ttg.type)
          f.in_sub_class ttg.name.class_name, base_name, &block
        else
          f.in_class ttg.name.class_name, &block
        end
      end

      def get_base_name(type)
        type.base &&
          !type.simple_content? &&
          @generator.get_ruby_type_name(type.base)
      end
    end
  end
end
