require 'wsdl_mapper/svc_desc_parsing/parser_base'
require 'wsdl_mapper/svc_desc/wsdl11/binding'

module WsdlMapper
  module SvcDescParsing
    class BindingParser < ParserBase
      def parse node
        name = parse_name_in_attribute 'name', node

        binding = Binding.new name
        binding.type_name = parse_name_in_attribute 'type', node

        each_element node do |child|
          parse_binding_child child, binding
        end

        @base.description.add_binding binding
      end

      def parse_binding_child node, binding
        case get_name node
        when OPERATION
          parse_binding_operation node, binding
        when Soap::BINDING
          parse_soap_binding node, binding
        else
          log_msg node, :unknown
        end
      end

      def parse_soap_binding node, binding
        binding.style = fetch_attribute_value 'style', node
        binding.transport = fetch_attribute_value 'transport', node
      end

      def parse_binding_operation node, binding
        name = parse_name_in_attribute 'name', node

        operation = Binding::Operation.new name

        each_element node do |child|
          parse_operation_child child, operation
        end

        binding.add_operation operation
      end

      def parse_operation_child node, operation
        case get_name node
        when INPUT
          parse_operation_input node, operation
        when OUTPUT
          parse_operation_output node, operation
        when Soap::OPERATION
          parse_operation_soap_action node, operation
        else
          log_msg node, :unknown
        end
      end

      def parse_operation_soap_action node, operation
        operation.soap_action = fetch_attribute_value 'soapAction', node
      end

      def parse_operation_input node, operation
        input = Binding::InputOutput.new

        each_element node do |child|
          parse_input_output_child child, input
        end

        operation.input = input
      end

      def parse_input_output_child node, in_out
        case get_name node
        when Soap::HEADER
          in_out.header = parse_header_body node
        when Soap::BODY
          in_out.body = parse_header_body node
        else
          log_msg node, :unknown
        end
      end

      def parse_header_body node
        hb = Binding::HeaderBody.new
        hb.use = fetch_attribute_value 'use', node
        hb.message_name = parse_name_in_attribute 'message', node
        hb.part_name = parse_name_in_attribute 'part', node
        hb
      end

      def parse_operation_output node, operation
        output = Binding::InputOutput.new

        each_element node do |child|
          parse_input_output_child child, output
        end

        operation.output = output
      end
    end
  end
end
