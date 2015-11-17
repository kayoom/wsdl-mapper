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
        @doc.encoding = 'UTF-8'
        @x = ::Nokogiri::XML::Builder.with @doc
        @tm = ::WsdlMapper::TypeMapping::DEFAULT
        @resolver = resolver
        @namespaces = namespaces
        if default_namespace
          @namespaces.default = default_namespace
        end
      end

      def get serializer_name
        @resolver.resolve serializer_name
      end

      def complex type_name, element_name, attributes
        # TODO: keep type_name parameter?
        @x.send expand_tag(*element_name), eval_attributes(attributes) do |x|
          yield self
        end
      end

      def simple type_name, element_name
        @x.send expand_tag(*element_name) do |x|
          yield self
        end
      end

      def text_builtin value, type_name
        @x.text builtin_to_xml(type_name, value)
      end

      def value_builtin element_name, value, type_name
        @x.send expand_tag(*element_name), builtin_to_xml(type_name, value)
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

      def builtin_to_xml type_name, value
        @tm.to_xml builtin(type_name), value
      end

      def eval_attributes attributes
        attributes.each_with_object({}) do |attr, hsh|
          attr_name = attr[0]
          ns = attr_name[0]
          name = attr_name[1]
          if ns
            prefix = @namespaces.prefix_for ns
            name = "#{prefix}:#{name}"
          end
          value = attr[1]
          type = attr[2]
          next if value.nil?

          hsh[name] = @tm.to_xml builtin(type), value
        end
      end
    end
  end
end
