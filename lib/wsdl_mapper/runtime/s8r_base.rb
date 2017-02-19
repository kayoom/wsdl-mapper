require 'wsdl_mapper/serializers/serializer_core'
require 'nokogiri/xml/node/save_options'

module WsdlMapper
  module Runtime
    class S8rBase
      # @param [WsdlMapper::Serializers::TypeDirectory] type_directory
      # @param [String] default_namespace Specify a `default_namespace` to skip namespace prefixes
      def initialize(type_directory, default_namespace = nil)
        @type_directory = type_directory
        @default_namespace = default_namespace
      end

      # Serializes the `envelope` and returns an XML string
      # @param [WsdlMapper::SvcDesc::Envelope] envelope
      # @return [String] `envelope` serialized as XML
      def to_xml(envelope)
        to_doc(envelope).to_xml save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION
      end

      # Serializes the `envelope` and returns a {Nokogiri::XML::Document}
      # @param [WsdlMapper::SvcDesc::Envelope] envelope
      # @return [Nokogiri::XML::Document] XML document containing the encoded `envelope`
      def to_doc(envelope)
        core = WsdlMapper::Serializers::SerializerCore.new resolver: @type_directory, default_namespace: @default_namespace
        build core, envelope
        core.to_doc
      end

      # Serializes the `envelope` using `x`
      # @param [WsdlMapper::Serializers::SerializerCore] x Serializer instance to use
      # @param [WsdlMapper::SvcDesc::Envelope] envelope
      def build(x, envelope)
        x.complex(nil, ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], []) do |x|
          build_header(x, envelope.header)
          build_body(x, envelope.body)
        end
      end

      # @abstract
      # @param [WsdlMapper::Serializers::SerializerCore] x Serializer instance to use
      # @param [WsdlMapper::Runtime::Header] header
      # noinspection RubyUnusedLocalVariable
      def build_header(x, header)
        raise NotImplementedError
      end

      # @abstract
      # @param [WsdlMapper::Serializers::SerializerCore] x Serializer instance to use
      # @param [WsdlMapper::Runtime::Body] body
      # noinspection RubyUnusedLocalVariable
      def build_body(x, body)
        raise NotImplementedError
      end
    end
  end
end
