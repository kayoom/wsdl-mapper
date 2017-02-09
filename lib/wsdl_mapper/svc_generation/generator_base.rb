require 'wsdl_mapper/generation/base'
require 'wsdl_mapper/svc_generation/type_to_generate'

module WsdlMapper
  module SvcGeneration
    class GeneratorBase < WsdlMapper::Generation::Base
      include WsdlMapper::Generation

      def initialize(generator)
        @generator = generator
        super(generator.context)
      end

      protected
      def get_formatter(io)
        @generator.get_formatter io
      end

      # @return [WsdlMapper::Naming::AbstractServiceNamer]
      def service_namer
        @generator.service_namer
      end

      # @return [WsdlMapper::Naming::AbstractNamer]
      def namer
        @generator.namer
      end

      def port_generator
        @generator.port_generator
      end

      def proxy_generator
        @generator.proxy_generator
      end

      def operation_generator
        @generator.operation_generator
      end

      def operation_s8r_generator
        @generator.operation_s8r_generator
      end

      def operation_d10r_generator
        @generator.operation_d10r_generator
      end

      def port_base
        @generator.port_base
      end

      def proxy_base
        @generator.proxy_base
      end

      def service_base
        @generator.service_base
      end

      def operation_base
        @generator.operation_base
      end

      def header_base
        @generator.header_base
      end

      def body_base
        @generator.body_base
      end

      def in_classes(f, *names, &block)
        @generator.in_classes f, *names, &block
      end

      def get_type_name(type)
        @generator.get_type_name type
      end

      class PartToGenerate < Struct.new(:type, :name, :property_name, :part)
      end

      class HeaderToGenerate < Struct.new(:type, :name, :property_name, :header)
      end

      def get_body_parts(in_out)
        parts = in_out.body.parts
        parts = in_out.target.message.each_part.to_a if parts.empty?

        parts.map do |part|
          type = part.type || part.element.type
          name = namer.get_type_name get_type_name type
          property_name = service_namer.get_body_property_name part.name

          PartToGenerate.new type, name, property_name, part
        end
      end

      def get_header_parts(in_out)
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
