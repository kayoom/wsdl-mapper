require 'nokogiri'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/dom/namespaces'
require 'wsdl_mapper/type_mapping'
require 'wsdl_mapper/dom/directory'

require 'wsdl_mapper/deserializers/class_mapping'
require 'wsdl_mapper/deserializers/soap_array_mapping'
require 'wsdl_mapper/deserializers/sax_document'

require 'wsdl_mapper/deserializers/errors'

module WsdlMapper
  module Deserializers
    class Deserializer
      include WsdlMapper::Dom

      def initialize(type_mapping: WsdlMapper::TypeMapping::DEFAULT, qualified_elements: false, qualified_attributes: false)
        @tm = type_mapping
        @element_mappings = Directory.new on_nil: Errors::UnknownElementError
        @type_mappings = Directory.new on_nil: Errors::UnknownTypeError
        @element_type_mappings = Directory.new do |name|
          get_type_mapping get_element_type name
        end
        @qualified_elements = qualified_elements
        @qualified_attributes = qualified_attributes
      end

      def from_xml(xml)
        doc = SaxDocument.new self
        parser = Nokogiri::XML::SAX::Parser.new doc
        parser.parse xml
        doc.object
      end

      def register_element(element_name, type_name)
        element_name = Name.get(*element_name)
        type_name = Name.get(*type_name)
        @element_mappings[element_name] = type_name
      end

      def register_type(type_name, class_mapping)
        type_name = Name.get(*type_name)
        @type_mappings[type_name] = class_mapping
      end

      def get_element_type(element_name)
        @element_mappings[element_name]
      end

      def get_element_type_mapping(element_name)
        @element_type_mappings[element_name]
      end

      def get_type_mapping(type_name)
        return if WsdlMapper::Dom::BuiltinType.builtin? type_name
        @type_mappings[type_name]
      end

      def to_ruby(type, value)
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
