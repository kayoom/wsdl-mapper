require 'wsdl_mapper/dom/name'

module WsdlMapper
  module Schema
    module SoapEncoding
      include WsdlMapper::Dom

      NS = 'http://schemas.xmlsoap.org/soap/encoding/'.freeze

      ARRAY = Name.new NS, 'Array'
      ARRAY_TYPE = Name.new NS, 'arrayType'
    end
  end
end
