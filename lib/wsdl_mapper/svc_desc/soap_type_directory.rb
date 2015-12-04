require 'wsdl_mapper/svc_desc/envelope'
require 'wsdl_mapper/deserializers/type_directory'

module WsdlMapper
  module SvcDesc
    SoapTypeDirectory = WsdlMapper::Deserializers::TypeDirectory.new

    EnvelopeDeserializer = SoapTypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ::WsdlMapper::SvcDesc::Envelope) do
      register_prop(:header, ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'])
      register_prop(:body, ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'])
    end
  end
end
