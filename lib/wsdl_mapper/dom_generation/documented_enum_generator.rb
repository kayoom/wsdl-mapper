require 'wsdl_mapper/dom_generation/default_enum_generator'
require 'wsdl_mapper/dom_generation/yard_doc_formatter'

module WsdlMapper
  module DomGeneration
    class DocumentedEnumGenerator < DefaultEnumGenerator

      protected
      def generate_constant_assignments f, values_to_generate
        yard = YardDocFormatter.new f
        values_to_generate.each do |vtg|
          if vtg.type.documentation.present?
            yard.text vtg.type.documentation.default
            yard.blank_line
          end
          yard.tag 'xml_value', vtg.type.value
          f.statement value_constant_assignment vtg
          f.blank_line
        end
        f.after_constants
      end

      def in_class f, ttg
        yard = YardDocFormatter.new f
        yard.class_doc ttg.type
        super
      end
    end
  end
end
