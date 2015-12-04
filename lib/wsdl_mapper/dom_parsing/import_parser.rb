require 'wsdl_mapper/dom_parsing/parser_base'
require 'wsdl_mapper/dom/soap_encoding_type'

module WsdlMapper
  module DomParsing
    class ImportParser < ParserBase
      def parse(node)
        # TODO: namespace attribute is optional
        case node.attributes['namespace'].value
        when SoapEncodingType::NAMESPACE, BuiltinType::NAMESPACE
          # ignore
        else
          import_schema node
        end
      end

      def import_schema(node)
        ns = fetch_attribute_value 'namespace', node
        location = fetch_attribute_value 'schemaLocation', node

        if location.nil?
          @base.schema.unresolved_imports << ns
        else
          doc = @base.import_resolver.resolve location
          schema = @base.dup.parse doc
          @base.schema.add_import ns, schema
        end
      end
    end
  end
end
