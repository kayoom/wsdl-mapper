require 'wsdl_mapper/serializers/serializer_core'

module WsdlMapper
  module Runtime
    class InputS8r
      def initialize(type_directory, default_namespace = nil)
        @type_directory = type_directory
        @default_namespace = default_namespace
      end

      # @param [WsdlMapper::SvcDesc::Envelope] envelope
      def to_xml(envelope)
        core = WsdlMapper::Serializers::SerializerCore.new resolver: @type_directory, default_namespace: @default_namespace
        build core, envelope
        core.to_xml
      end

      def build(x, envelope)
        x.complex(nil, ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], []) do |x|
          build_header(x, envelope.header)
          build_body(x, envelope.body)
        end
      end

      def build_header(x, header)
        raise NotImplementedError
      end

      def build_body(x, body)
        raise NotImplementedError
      end
    end
  end
end
