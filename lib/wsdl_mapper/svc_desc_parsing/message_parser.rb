require 'wsdl_mapper/svc_desc_parsing/parser_base'
require 'wsdl_mapper/svc_desc/wsdl11/message'

module WsdlMapper
  module SvcDescParsing
    class MessageParser < ParserBase
      def parse node
        name = parse_name_in_attribute 'name', node

        message = Message.new name

        each_element node do |child|
          parse_message_child child, message
        end

        @base.description.add_message message
      end

      def parse_message_child node, message
        case get_name(node)
        when PART
          parse_part node, message
        else
          log_msg node, :unknown
        end
      end

      def parse_part node, message
        name = parse_name_in_attribute 'name', node

        part = Message::Part.new name

        part.element_name = parse_name_in_attribute 'element', node
        part.type_name = parse_name_in_attribute 'type', node

        message.add_part part
      end
    end
  end
end
