require 'wsdl_mapper/dom/name'

module WsdlMapper
  module SvcDescParsing
    module Soap
      include WsdlMapper::Dom

      NS = 'http://schemas.xmlsoap.org/wsdl/soap/'.freeze
      BINDING = Name.get NS, 'binding'
      OPERATION = Name.get NS, 'operation'
      HEADER = Name.get NS, 'header'
      BODY = Name.get NS, 'body'
      ADDRESS = Name.get NS, 'address'
      FAULT = Name.get NS, 'fault'
      HEADER_FAULT = Name.get NS, 'headerfault'
    end
  end
end
