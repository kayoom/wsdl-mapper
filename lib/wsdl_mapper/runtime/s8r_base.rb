require 'wsdl_mapper/serializers/serializer_core'
require 'nokogiri/xml/node/save_options'

module WsdlMapper
  module Runtime
    class S8rBase
      def initialize(type_directory, default_namespace = nil)
        @type_directory = type_directory
        @default_namespace = default_namespace
      end

      # @param [WsdlMapper::SvcDesc::Envelope] envelope
      def to_xml(envelope)
        to_doc(envelope).to_xml save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION
      end

      def to_doc(envelope)
        core = WsdlMapper::Serializers::SerializerCore.new resolver: @type_directory, default_namespace: @default_namespace
        build core, envelope
        core.to_doc
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
