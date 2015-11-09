require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/dom/bounds'

module WsdlMapper
  module DomParsing
    module Xsd
      include WsdlMapper::Dom

      NS = 'http://www.w3.org/2001/XMLSchema'.freeze

      IMPORT = Name.get NS, 'import'
      SCHEMA = Name.get NS, 'schema'
      ELEMENT = Name.get NS, 'element'
      SEQUENCE = Name.get NS, 'sequence'
      COMPLEX_TYPE = Name.get NS, 'complexType'
      SIMPLE_TYPE = Name.get NS, 'simpleType'
      ANNOTATION = Name.get NS, 'annotation'
      DOCUMENTATION = Name.get NS, 'documentation'
      APPINFO = Name.get NS, 'appinfo'
      COMPLEX_CONTENT = Name.get NS, 'complexContent'
      SIMPLE_CONTENT = Name.get NS, 'simpleContent'
      EXTENSION = Name.get NS, 'extension'
      RESTRICTION = Name.get NS, 'restriction'
      ENUMERATION = Name.get NS, 'enumeration'
      ATTRIBUTE = Name.get NS, 'attribute'
      ALL = Name.get NS, 'all'

      NS_DECL_PREFIX = 'xmlns'
      TARGET_NS = 'targetNamespace'

      ELEMENT_FORM_DEFAULT = "elementFormDefault"
      ATTRIBUTE_FORM_DEFAULT = "attributeFormDefault"

      DEFAULT_BOUNDS = {
        SEQUENCE  => Bounds.new(min: 1, max: 1),
        ALL       => Bounds.new(min: 0, max: 1)
      }
    end
  end
end
