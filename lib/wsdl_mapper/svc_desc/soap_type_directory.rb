require 'wsdl_mapper/svc_desc/envelope'
require 'wsdl_mapper/svc_desc/fault'
require 'wsdl_mapper/deserializers/type_directory'

module WsdlMapper
  module SvcDesc
    SoapTypeDirectory = WsdlMapper::Deserializers::TypeDirectory.new

    FaultDeserializer = SoapTypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Fault'], ::WsdlMapper::SvcDesc::Fault) do
      register_prop(:code, ['http://schemas.xmlsoap.org/soap/envelope/', 'faultcode'], ['http://www.w3.org/2001/XMLSchema', 'string'])
      register_prop(:string, ['http://schemas.xmlsoap.org/soap/envelope/', 'faultstring'], ['http://www.w3.org/2001/XMLSchema', 'string'])
      register_prop(:actor, ['http://schemas.xmlsoap.org/soap/envelope/', 'faultactor'], ['http://www.w3.org/2001/XMLSchema', 'string'])
      register_prop(:detail, ['http://schemas.xmlsoap.org/soap/envelope/', 'detail'], ['http://www.w3.org/2001/XMLSchema', 'string'])
    end

    EnvelopeDeserializer = SoapTypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ::WsdlMapper::SvcDesc::Envelope) do
      register_prop(:header, ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'])
      register_prop(:body, ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'])
    end
  end
end
