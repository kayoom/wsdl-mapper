require 'nokogiri'

require 'wsdl_mapper/type_mapping'
require 'wsdl_mapper/dom/builtin_type'
require 'wsdl_mapper/dom/soap_encoding_type'
require 'wsdl_mapper/dom/namespaces'

module WsdlMapper
  module Serializers
    class Serializer
      def initialize resolver:, namespaces: WsdlMapper::Dom::Namespaces.new, default_namespace: nil
        @doc = ::Nokogiri::XML::Document.new
        @doc.encoding = "UTF-8"
        @x = ::Nokogiri::XML::Builder.with @doc
        @tm = ::WsdlMapper::TypeMapping::DEFAULT
        @resolver = resolver
        @namespaces = namespaces
        if default_namespace
          @namespaces.default = default_namespace
        end
        # @current_prefix = nil
      end

      def get serializer_name
        @resolver.resolve serializer_name
      end

      def complex ns, tag, attributes
        @x.send expand_tag(ns, tag), eval_attributes(attributes) do |x|
          yield self
        end
      end

      def simple ns, tag
        @x.send expand_tag(ns, tag) do |x|
          yield self
        end
      end

      def text_builtin value, type
        @x.text builtin_to_xml(type, value)
      end

      def value_builtin ns, tag, value, type
        @x.send expand_tag(ns, tag), builtin_to_xml(type, value)
      end

      def to_xml
        @namespaces.each do |(prefix, url)|
          @doc.root.add_namespace prefix, url
        end
        @doc.to_xml
      end

      def soap_enc
        @soap_enc ||= ::WsdlMapper::Dom::SoapEncodingType::NAMESPACE
      end

      def xsd
        @xsd ||= ::WsdlMapper::Dom::BuiltinType::NAMESPACE
      end

      protected
      def expand_tag ns, tag
        prefix = @namespaces.prefix_for ns
        prefix ? "#{prefix}:#{tag}" : tag
      end

      def builtin name
        ::WsdlMapper::Dom::BuiltinType[name]
      end

      def builtin_to_xml type, value
        @tm.to_xml builtin(type), value
      end

      def eval_attributes attributes
        attributes.each_with_object({}) do |attr, hsh|
          ns = attr[0]
          key = attr[1]
          if ns
            prefix = @namespaces.prefix_for ns
            key = "#{prefix}:#{key}"
          end
          value = attr[2]
          type = attr[3]
          next if value.nil?

          hsh[key] = @tm.to_xml builtin(type), value
        end
      end
    end
  end
end
