require 'nokogiri'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/dom/namespaces'
require 'wsdl_mapper/type_mapping'
require 'wsdl_mapper/dom/directory'

require 'wsdl_mapper/deserializers/class_mapping'
require 'wsdl_mapper/deserializers/sax_document'

module WsdlMapper
  module Deserializers
    class Deserializer
      include WsdlMapper::Dom

      def initialize type_mapping: WsdlMapper::TypeMapping::DEFAULT, qualified_elements: false, qualified_attributes: false
        @tm = type_mapping
        @mappings = Directory.new
        @qualified_elements = qualified_elements
        @qualified_attributes = qualified_attributes
      end

      def from_xml xml
        doc = SaxDocument.new self
        parser = Nokogiri::XML::SAX::Parser.new doc
        parser.parse xml
        doc.object
      end

      def register name, mapping
        @mappings[name] = mapping
      end

      def get_mapping type_name
        @mappings[type_name]
      end

      def to_ruby type, value
        @tm.to_ruby type, value
      end

      def qualified_elements?
        !!@qualified_elements
      end

      def qualified_attributes?
        !!@qualified_attributes
      end
    end
  end
end
