require 'wsdl_mapper/generation/default_class_generator'
require 'wsdl_mapper/generation/yard_doc_formatter'

module WsdlMapper
  module Generation
    class DocumentedClassGenerator < DefaultClassGenerator

      protected
      def open_class f, ttg
        yard = YardDocFormatter.new f
        yard.class_doc ttg.type

        super
      end

      def generate_property_attributes f, properties
        return unless properties.any?
        yard = YardDocFormatter.new f

        properties.each do |p|
          name = @generator.namer.get_property_name p
          type = @generator.get_ruby_type_name p.type

          yard.attribute! name.attr_name, type, p.documentation.default do
            yard.tag :xml_name, p.name.name
          end
          f.attr_accessor name.attr_name
        end
      end

      def generate_attribute_attributes f, attributes
        return unless attributes.any?
        yard = YardDocFormatter.new f

        attributes.each do |a|
          name = @generator.namer.get_attribute_name a
          type = @generator.get_ruby_type_name a.type

          yard.attribute! name.attr_name, type, a.documentation.default do
            yard.tag :xml_name, a.name
          end
          f.attr_accessor name.attr_name
        end
      end
    end
  end
end
