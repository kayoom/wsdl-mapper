module WsdlMapper
  module DomGeneration
    class DefaultValueDefaultsGenerator
      def initialize(generator)
        @generator = generator
      end

      def generate_for_attribute(attribute)
        if attribute.default?
          xml_val = attribute.default
          return @generator.value_generator.generate_nil unless xml_val

          ruby_val = @generator.type_mapping.to_ruby attribute.type_name, xml_val
          @generator.value_generator.generate ruby_val
        elsif attribute.fixed?
          xml_val = attribute.fixed

          ruby_val = @generator.type_mapping.to_ruby attribute.type_name, xml_val
          @generator.value_generator.generate ruby_val
        else
          @generator.value_generator.generate_nil
        end
      end

      def generate_for_property(property)
        if property.default? && !property.array?
          xml_val = property.default
          return @generator.value_generator.generate_nil unless xml_val

          ruby_val = @generator.type_mapping.to_ruby property.type_name, xml_val
          @generator.value_generator.generate ruby_val
        elsif property.array? && !property.default?
          @generator.value_generator.generate_empty_array
        elsif property.single? && !builtin?(property.type)
          name = @generator.namer.get_type_name property.type
          "#{name.name}.new"
        else
          @generator.value_generator.generate_nil
        end
        # TODO: what about array type properties with defaults?
        # TODO: fixed values
        # TODO: simple types extensions/restrictions of builtin types
      end

      protected
      def builtin?(type)
        type.name.ns == WsdlMapper::Dom::BuiltinType::NAMESPACE
      end
    end
  end
end
