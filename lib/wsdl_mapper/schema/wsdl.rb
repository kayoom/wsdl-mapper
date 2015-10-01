require 'wsdl_mapper/dom/name'

module WsdlMapper
  module Schema
    module Wsdl
      include WsdlMapper::Dom

      NS = 'http://schemas.xmlsoap.org/wsdl/'.freeze

      ARRAY_TYPE = Name.new NS, 'arrayType'
    end
  end
end
