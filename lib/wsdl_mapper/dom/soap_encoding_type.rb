require 'wsdl_mapper/dom/type_base'
require 'wsdl_mapper/dom/shallow_schema'

module WsdlMapper
  module Dom
    class SoapEncodingType < TypeBase
      NAMESPACE = 'http://schemas.xmlsoap.org/soap/encoding/'.freeze

      extend ShallowSchema
      self.namespace = NAMESPACE
    end
  end
end
