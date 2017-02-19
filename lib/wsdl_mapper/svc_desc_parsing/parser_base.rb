require 'wsdl_mapper/parsing/base'

require 'wsdl_mapper/svc_desc/wsdl11/base'
require 'wsdl_mapper/svc_desc_parsing/wsdl11'
require 'wsdl_mapper/svc_desc_parsing/soap'
require 'wsdl_mapper/svc_desc_parsing/soap12'
require 'wsdl_mapper/svc_desc_parsing/http'
require 'wsdl_mapper/svc_desc_parsing/soap_enc'
require 'wsdl_mapper/svc_desc_parsing/soap_http'

module WsdlMapper
  module SvcDescParsing
    class ParserBase < WsdlMapper::Parsing::Base
      include WsdlMapper::SvcDesc::Wsdl11
      include WsdlMapper::SvcDescParsing::Wsdl11

      Soap = WsdlMapper::SvcDescParsing::Soap
      Soap12 = WsdlMapper::SvcDescParsing::Soap12
      Http = WsdlMapper::SvcDescParsing::Http
      SoapEnc = WsdlMapper::SvcDescParsing::SoapEnc
      SoapHttp = WsdlMapper::SvcDescParsing::SoapHttp
    end
  end
end
