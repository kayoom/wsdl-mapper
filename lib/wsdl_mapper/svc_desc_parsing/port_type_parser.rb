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
        when DOCUMENTATION
          @base.parse_documentation node, operation
        else
          log_msg node, :unknown
        end
      end

      def parse_operation node, port_type
        name = parse_name_in_attribute 'name', node

        operation = PortType::Operation.new name

        sequence = []
        each_element node do |child|
          sequence << parse_operation_child(child, operation)
        end
        sequence.compact!
        operation.type = determine_type sequence

        port_type.add_operation operation
      end

      def determine_type sequence
        case sequence[0, 2]
        when [INPUT]
          :one_way
        when [INPUT, OUTPUT]
          :request_response
        when [OUTPUT, INPUT]
          :solicit_response
        when [OUTPUT]
          :notification
        end
      end

      def parse_operation_child node, operation
        name = get_name(node)
        case name
        when INPUT
          parse_operation_input node, operation
          name
        when OUTPUT
          parse_operation_output node, operation
          name
        when FAULT
          parse_operation_fault node, operation
          name
        when DOCUMENTATION
          @base.parse_documentation node, operation
          nil
        else
          log_msg node, :unknown
          nil
        end
      end

      def parse_operation_input node, operation
        name = parse_name_in_attribute 'name', node
        input = PortType::InputOutput.new name
        input.message_name = parse_name_in_attribute 'message', node
        operation.input = input
      end

      def parse_operation_output node, operation
        name = parse_name_in_attribute 'name', node
        output = PortType::InputOutput.new name
        output.message_name = parse_name_in_attribute 'message', node
        operation.output = output
      end

      def parse_operation_fault node, operation
        name = parse_name_in_attribute 'name', node
        fault = PortType::InputOutput.new name
        fault.message_name = parse_name_in_attribute 'message', node
        operation.add_fault fault
      end
    end
  end
end
