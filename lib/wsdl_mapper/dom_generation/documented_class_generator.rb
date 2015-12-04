require 'wsdl_mapper/dom_generation/default_class_generator'
require 'wsdl_mapper/generation/yard_doc_formatter'

module WsdlMapper
  module DomGeneration
    class DocumentedClassGenerator < DefaultClassGenerator

      protected
      def in_class(f, ttg)
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        yard.class_doc ttg.type

        super
      end

      def generate_property_attributes(f, properties)
        return unless properties.any?
        yard = WsdlMapper::Generation::YardDocFormatter.new f

        properties.each do |p|
          name = @generator.namer.get_property_name p

          type = if p.type.name == WsdlMapper::Dom::BuiltinType[:boolean].name
            'true, false'
          else
            @generator.get_ruby_type_name p.type
          end
          type ||= 'Object'

          if p.array?
            type = "Array<#{type}>"
          end

          # TODO: more xml info? (bounds etc), e.g. # @xml_bounds min: 0, max: unbounded
          yard.attribute! name.attr_name, type, p.documentation.default do
            yard.tag :xml_name, p.name.name
          end
          f.attr_accessors name.attr_name
        end
      end

      def generate_attribute_attributes(f, attributes)
        return unless attributes.any?
        yard = WsdlMapper::Generation::YardDocFormatter.new f

        attributes.each do |a|
          name = @generator.namer.get_attribute_name a
          type = @generator.get_ruby_type_name a.type

          yard.attribute! name.attr_name, type, a.documentation.default do
            yard.tag :xml_name, a.name.name
          end
          f.attr_accessors name.attr_name
        end
      end
    end
  end
end
