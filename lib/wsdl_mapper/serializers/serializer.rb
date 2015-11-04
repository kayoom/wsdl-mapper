require 'nokogiri'

require 'wsdl_mapper/type_mapping'
require 'wsdl_mapper/dom/builtin_type'
require 'wsdl_mapper/dom/soap_encoding_type'

module WsdlMapper
  module Serializers
    class Serializer
      def initialize resolver:
        @doc = ::Nokogiri::XML::Document.new
        @doc.encoding = "UTF-8"
        @x = ::Nokogiri::XML::Builder.with @doc
        @tm = ::WsdlMapper::TypeMapping::DEFAULT
        @resolver = resolver
      end

      def get serializer_name
        @resolver.resolve serializer_name
      end

      def complex tag, attributes = []
        @x.send tag, eval_attributes(attributes) do |x|
          yield self
        end
        add_namespaces
      end

      def simple tag
        @x.send tag do |x|
          yield self
        end
        add_namespaces
      end

      def text_builtin value, type
        @x.text builtin_to_xml(type, value)
      end

      def value_builtin tag, value, type
        @x.send tag, builtin_to_xml(type, value)
        add_namespaces
      end

      def to_xml
        @doc.to_xml
      end

      def soap_enc
        @soap_enc ||= begin
          add_namespace :soapenc, ::WsdlMapper::Dom::SoapEncodingType::NAMESPACE
          :soapenc
        end
      end

      def xsd
        @xsd ||= begin
          add_namespace :xsd, ::WsdlMapper::Dom::BuiltinType::NAMESPACE
          :xsd
        end
      end

      def add_namespace prefix, url
        if @doc.root
          @doc.root.add_namespace prefix.to_s, url
        else
          @namespaces ||= {}
          @namespaces[prefix] = url
        end
        self
      end

      protected
      def add_namespaces
        return unless @namespaces
        @namespaces.each do |prefix, url|
          @doc.root.add_namespace prefix.to_s, url
        end
        @namespaces = nil
      end

      def builtin name
        ::WsdlMapper::Dom::BuiltinType[name]
      end

      def builtin_to_xml type, value
        @tm.to_xml builtin(type), value
      end

      def eval_attributes attributes
        attributes.each_with_object({}) do |attr, hsh|
          key = attr[0]
          if key.is_a? ::Array
            key = "#{key[0]}:#{key[1]}"
          end
          value = attr[1]
          type = attr[2]
          next if value.nil?

          hsh[key] = @tm.to_xml builtin(type), value
        end
      end
    end
  end
end
