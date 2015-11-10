require 'wsdl_mapper/dom/name'

module WsdlMapper
  module SvcDescParsing
    module SoapEnc
      include WsdlMapper::Dom

      NS = 'http://schemas.xmlsoap.org/wsdl/soap/encoding/'.freeze
      ARRAY_TYPE = Name.get NS, 'arrayType'
      ARRAY = Name.get NS, 'Array'
    end
  end
end
