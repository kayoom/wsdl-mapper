require 'wsdl_mapper/deserializers/element_directory'
require 'wsdl_mapper/svc_desc/envelope'
require 'wsdl_mapper/svc_desc/soap_type_directory'

module WsdlMapper
  module SvcDesc
    SoapElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(SoapTypeDirectory) do
      register_element ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], 'wsdl_mapper/svc_desc/envelope', ::WsdlMapper::SvcDesc::Envelope

      def require(path); end
    end
  end
end
