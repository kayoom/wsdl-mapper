require 'wsdl_mapper/dom/name'

module WsdlMapper
  module Schema
    module Xsd
      include WsdlMapper::Dom

      NS = 'http://www.w3.org/2001/XMLSchema'.freeze

      SCHEMA = Name.new NS, 'schema'
      ELEMENT = Name.new NS, 'element'
      SEQUENCE = Name.new NS, 'sequence'
      COMPLEX_TYPE = Name.new NS, 'complexType'
      SIMPLE_TYPE = Name.new NS, 'simpleType'
      ANNOTATION = Name.new NS, 'annotation'
      DOCUMENTATION = Name.new NS, 'documentation'
      APPINFO = Name.new NS, 'appinfo'
      COMPLEX_CONTENT = Name.new NS, 'complexContent'
      EXTENSION = Name.new NS, 'extension'
      RESTRICTION = Name.new NS, 'restriction'
      ENUMERATION = Name.new NS, 'enumeration'
      ATTRIBUTE = Name.new NS, 'attribute'

      NS_DECL_PREFIX = 'xmlns'
      TARGET_NS = 'targetNamespace'
    end
  end
end
