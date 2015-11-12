require 'wsdl_mapper/svc_desc_parsing/parser_base'
require 'wsdl_mapper/dom_parsing/parser'

module WsdlMapper
  module SvcDescParsing
    class TypesParser < ParserBase
      def parse node
        each_element node do |child|
          parse_types_child child
        end
      end

      def parse_types_child node
        case get_name node
        when WsdlMapper::DomParsing::Xsd::SCHEMA
          parse_schema node
        else
          log_msg node, :unknown
        end
      end

      def parse_schema node
        parser = WsdlMapper::DomParsing::Parser.new
        @base.description.add_schema parser.parse(node, parse_only: true)
        parser.log_msgs.each do |msg|
          @base.log_msgs << msg
        end
      end
    end
  end
end
