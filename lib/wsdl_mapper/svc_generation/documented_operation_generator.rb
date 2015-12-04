require 'wsdl_mapper/svc_generation/operation_generator'
require 'wsdl_mapper/generation/yard_doc_formatter'

module WsdlMapper
  module SvcGeneration
    class DocumentedOperationGenerator < OperationGenerator
      def generate_header_accessors(f, parts)
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        parts.each do |p|
          attr_name = p.property_name.attr_name
          type = p.name.name
          yard.attribute! attr_name, type, nil
          f.attr_accessors p.property_name.attr_name
        end
      end

      def generate_body_accessors(f, parts)
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        parts.each do |p|
          attr_name = p.property_name.attr_name
          type = p.name.name
          yard.attribute! attr_name, type, nil
          f.attr_accessors p.property_name.attr_name
        end
      end
    end
  end
end
