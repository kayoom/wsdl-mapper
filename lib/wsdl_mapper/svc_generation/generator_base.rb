require 'wsdl_mapper/generation/base'
require 'wsdl_mapper/svc_generation/type_to_generate'

module WsdlMapper
  module SvcGeneration
    class GeneratorBase < WsdlMapper::Generation::Base
      include WsdlMapper::Generation

      def initialize generator
        @generator = generator
        @context = generator.context
      end

      protected
      def get_formatter io
        @generator.get_formatter io
      end

      def service_namer
        @generator.service_namer
      end

      def namer
        @generator.namer
      end

      def port_generator
        @generator.port_generator
      end

      def operation_generator
        @generator.operation_generator
      end

      def port_base
        @generator.port_base
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

      def in_classes f, *names, &block
        @generator.in_classes f, *names, &block
      end

      def get_type_name type
        @generator.get_type_name type
      end
    end
  end
end
