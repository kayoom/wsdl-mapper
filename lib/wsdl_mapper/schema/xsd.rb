require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/dom/bounds'

module WsdlMapper
  module Schema
    module Xsd
      include WsdlMapper::Dom

      NS = 'http://www.w3.org/2001/XMLSchema'.freeze

      IMPORT = Name.new NS, 'import'
      SCHEMA = Name.new NS, 'schema'
      ELEMENT = Name.new NS, 'element'
      SEQUENCE = Name.new NS, 'sequence'
      COMPLEX_TYPE = Name.new NS, 'complexType'
      SIMPLE_TYPE = Name.new NS, 'simpleType'
      ANNOTATION = Name.new NS, 'annotation'
      DOCUMENTATION = Name.new NS, 'documentation'
      APPINFO = Name.new NS, 'appinfo'
      COMPLEX_CONTENT = Name.new NS, 'complexContent'
      SIMPLE_CONTENT = Name.new NS, 'simpleContent'
      EXTENSION = Name.new NS, 'extension'
      RESTRICTION = Name.new NS, 'restriction'
      ENUMERATION = Name.new NS, 'enumeration'
      ATTRIBUTE = Name.new NS, 'attribute'
      ALL = Name.new NS, 'all'

      NS_DECL_PREFIX = 'xmlns'
      TARGET_NS = 'targetNamespace'

      DEFAULT_BOUNDS = {
        SEQUENCE  => Bounds.new(min: 1, max: 1),
        ALL       => Bounds.new(min: 0, max: 1)
      }
    end
  end
end
