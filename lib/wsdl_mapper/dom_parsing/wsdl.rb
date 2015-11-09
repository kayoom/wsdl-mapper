require 'wsdl_mapper/dom/name'

module WsdlMapper
  module DomParsing
    module Wsdl
      include WsdlMapper::Dom

      NS = 'http://schemas.xmlsoap.org/wsdl/'.freeze

      ARRAY_TYPE = Name.get NS, 'arrayType'
    end
  end
end
