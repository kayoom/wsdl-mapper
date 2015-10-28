require 'wsdl_mapper/generation/default_class_generator'
require 'wsdl_mapper/generation/yard_doc_formatter'

module WsdlMapper
  module Generation
    class DocumentedClassGenerator < DefaultClassGenerator

      protected
      def open_class f, ttg
        if ttg.type.documentation.present?
          doc = ttg.type.documentation.default
          yard = YardDocFormatter.new f

          doc = doc.strip.gsub(/^[\t ]+/, '')
          yard.text doc
          yard.blank_line
          yard.tag :xml_name, ttg.type.name.name

          if ttg.type.name.ns
            yard.tag :xml_namespace, ttg.type.name.ns
          end
        end

        super
      end

      def generate_property_attributes f, properties
        return unless properties.any?
        yard = YardDocFormatter.new f

        properties.each do |p|
          name = @generator.namer.get_property_name p
          type = if WsdlMapper::Dom::BuiltinType.builtin? p.type.name
            @generator.type_mapping.ruby_type p.type.name
          else
            @generator.namer.get_type_name(p.type).name
          end

          yard.attribute! name.attr_name, type, p.documentation.default do
            yard.tag :xml_name, p.name.name
          end
          f.attr_accessor name.attr_name
        end
      end
    end
  end
end
