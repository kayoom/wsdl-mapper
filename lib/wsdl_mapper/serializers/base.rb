require 'nokogiri'

require 'wsdl_mapper/type_mapping'
require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module Serializers
    class Base
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
      end

      def simple tag
        @x.send tag do |x|
          yield self
        end
      end

      def text_builtin value, type
        @x.text builtin_to_xml(type, value)
      end

      def value_builtin tag, value, type
        @x.send tag, builtin_to_xml(type, value)
      end

      def to_xml
        @doc.to_xml
      end

      protected
      def builtin name
        ::WsdlMapper::Dom::BuiltinType[name]
      end

      def builtin_to_xml type, value
        @tm.to_xml builtin(type), value
      end

      def eval_attributes attributes
        attributes.each_with_object({}) do |attr, hsh|
          key = attr[0]
          value = attr[1]
          type = attr[2]
          next if value.nil?

          hsh[key] = @tm.to_xml builtin(type), value
        end
      end
    end
  end
end
