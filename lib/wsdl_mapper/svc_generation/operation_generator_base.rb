require 'wsdl_mapper/svc_generation/generator_base'

module WsdlMapper
  module SvcGeneration
    class OperationGeneratorBase < GeneratorBase
      class PartToGenerate < Struct.new(:type, :name, :property_name, :part)
      end

      class HeaderToGenerate < Struct.new(:type, :name, :property_name, :header)
      end

      def get_body_parts in_out
        parts = in_out.body.parts
        parts = in_out.target.message.each_part.to_a if parts.empty?

        parts.map do |part|
          type = part.type || part.element.type
          name = namer.get_type_name get_type_name type
          property_name = service_namer.get_body_property_name part.name

          PartToGenerate.new type, name, property_name, part
        end
      end

      def get_header_parts in_out
        in_out.each_header.map do |header|
          type = header.part.type || header.part.element.type
          name = namer.get_type_name get_type_name type
          property_name = service_namer.get_header_property_name header.message_name, header.part_name

          HeaderToGenerate.new type, name, property_name, header
        end
      end
    end
  end
end
