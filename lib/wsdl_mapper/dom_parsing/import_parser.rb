require 'wsdl_mapper/dom_parsing/parser_base'
require 'wsdl_mapper/dom/soap_encoding_type'

module WsdlMapper
  module DomParsing
    class ImportParser < ParserBase
      def parse node
        # TODO: namespace attribute is optional
        case node.attributes['namespace'].value
        when SoapEncodingType::NAMESPACE, BuiltinType::NAMESPACE
          # ignore
        else
          import_schema node
        end
      end

      def import_schema node
        ns = node.attributes['namespace'].value
        location = node.attributes['schemaLocation'].value
        doc = @base.import_resolver.resolve location
        schema = @base.dup.parse doc
        @base.schema.add_import ns, schema
      end
    end
  end
end
