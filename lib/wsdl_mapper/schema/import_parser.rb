require 'wsdl_mapper/schema/parser_base'
require 'wsdl_mapper/dom/soap_encoding_type'

module WsdlMapper
  module Schema
    class ImportParser < ParserBase
      def parse node
        case node.attributes['namespace'].value
        when SoapEncodingType::NAMESPACE, BuiltinType::NAMESPACE
          # ignore
        else
          log_msg node, :unsupported_import
        end
      end
    end
  end
end
