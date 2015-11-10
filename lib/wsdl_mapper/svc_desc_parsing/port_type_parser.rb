require 'wsdl_mapper/svc_desc_parsing/parser_base'
require 'wsdl_mapper/svc_desc/wsdl11/port_type'

module WsdlMapper
  module SvcDescParsing
    class PortTypeParser < ParserBase
      def parse node
        name = parse_name_in_attribute 'name', node

        port_type = PortType.new name

        each_element node do |child|
          parse_port_type_child child, port_type
        end

        @base.description.add_port_type port_type
      end

      def parse_port_type_child node, port_type
        case get_name(node)
        when OPERATION
          parse_operation node, port_type
        else
          log_msg node, :unknown
        end
      end

      def parse_operation node, port_type
        name = parse_name_in_attribute 'name', node

        operation = PortType::Operation.new name

        each_element node do |child|
          parse_operation_child child, operation
        end

        port_type.add_operation operation
      end

      def parse_operation_child node, operation
        case get_name(node)
        when INPUT
          parse_operation_input node, operation
        when OUTPUT
          parse_operation_output node, operation
        else
          log_msg node, :unknown
        end
      end

      def parse_operation_input node, operation
        operation.input_message_name = parse_name_in_attribute 'message', node
      end

      def parse_operation_output node, operation
        operation.output_message_name = parse_name_in_attribute 'message', node
      end
    end
  end
end
