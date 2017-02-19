require 'wsdl_mapper/dom/name'

module WsdlMapper
  module SvcDescParsing
    module Http
      include WsdlMapper::Dom

      NS = 'http://schemas.xmlsoap.org/wsdl/http/'.freeze
      BINDING = Name.get NS, 'binding'
      OPERATION = Name.get NS, 'operation'
      ADDRESS = Name.get NS, 'address'
    end
  end
end
