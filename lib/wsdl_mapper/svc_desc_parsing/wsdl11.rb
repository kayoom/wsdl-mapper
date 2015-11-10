require 'wsdl_mapper/dom/name'

module WsdlMapper
  module SvcDescParsing
    module Wsdl11
      include WsdlMapper::Dom

      NS = 'http://schemas.xmlsoap.org/wsdl/'.freeze

      ARRAY_TYPE = Name.get NS, 'arrayType'

      DEFINITIONS = Name.get NS, 'definitions'
      TYPES = Name.get NS, 'types'
      MESSAGE = Name.get NS, 'message'
      PART = Name.get NS, 'part'
      PORT_TYPE = Name.get NS, 'portType'
      OPERATION = Name.get NS, 'operation'
      DOCUMENTATION = Name.get NS, 'documentation'
      INPUT = Name.get NS, 'input'
      OUTPUT = Name.get NS, 'output'
      BINDING = Name.get NS, 'binding'
      SERVICE = Name.get NS, 'service'
      PORT = Name.get NS, 'port'
    end
  end
end
