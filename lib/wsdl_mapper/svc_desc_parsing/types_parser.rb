require 'wsdl_mapper/svc_desc_parsing/parser_base'
require 'wsdl_mapper/dom_parsing/parser'

module WsdlMapper
  module SvcDescParsing
    class TypesParser < ParserBase
      def parse node
        parser = WsdlMapper::DomParsing::Parser.new
        @base.description.schema = parser.parse node
      end
    end
  end
end
