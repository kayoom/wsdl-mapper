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
        when FAULT
          parse_operation_fault node, operation
        when Soap::OPERATION
          parse_operation_soap_action node, operation
        # TODO: fault
        else
          log_msg node, :unknown
        end
      end

      def parse_operation_soap_action node, operation
        operation.soap_action = fetch_attribute_value 'soapAction', node
      end

      def parse_operation_input node, operation
        name = parse_name_in_attribute 'name', node
        input = Binding::InputOutput.new name

        each_element node do |child|
          parse_input_output_child child, input
        end

        operation.input = input
      end

      def parse_input_output_child node, in_out
        case get_name node
        when Soap::HEADER
          in_out.add_header parse_header node
        when Soap::BODY
          in_out.body = parse_body node
        # TODO: headerfault
        else
          log_msg node, :unknown
        end
      end

      def parse_body node
        body = Binding::Body.new
        body.use = fetch_attribute_value 'use', node
        body.encoding_styles = fetch_attribute_value('encodingStyle', node, "").split " "
        body.namespace = fetch_attribute_value 'namespace', node
        body.part_names = fetch_attribute_value('parts', node, "").split(" ").map { |s| parse_name(s) }
        body
      end

      def parse_header node
        header = Binding::Header.new
        header.use = fetch_attribute_value 'use', node
        header.message_name = parse_name_in_attribute 'message', node
        header.part_name = parse_name_in_attribute 'part', node
        header.encoding_styles = fetch_attribute_value('encodingStyle', node, "").split " "
        header.namespace = fetch_attribute_value 'namespace', node

        each_element node do |child|
          parse_header_child child, header
        end

        header
      end

      def parse_header_child node, header
        case get_name node
        when Soap::HEADER_FAULT
          parse_header_fault node, header
        else
          log_msg node, :unknown
        end
      end

      def parse_header_fault node, header
        header_fault = Binding::HeaderFault.new
        header_fault.use = fetch_attribute_value 'use', node
        header_fault.message_name = parse_name_in_attribute 'message', node
        header_fault.part_name = parse_name_in_attribute 'part', node
        header_fault.encoding_styles = fetch_attribute_value('encodingStyle', node, "").split " "
        header_fault.namespace = fetch_attribute_value 'namespace', node

        header.add_header_fault header_fault
      end

      def parse_operation_output node, operation
        name = parse_name_in_attribute 'name', node
        output = Binding::InputOutput.new name

        each_element node do |child|
          parse_input_output_child child, output
        end

        operation.output = output
      end

      def parse_operation_fault node, operation
        name = parse_name_in_attribute 'name', node
        fault = Binding::Fault.new name

        each_element node do |child|
          parse_fault_child child, fault
        end

        operation.add_fault fault
      end

      def parse_fault_child node, fault
        case get_name node
        when Soap::FAULT
          parse_soap_fault node, fault
        else
          log_msg node, :unknown
        end
      end

      def parse_soap_fault node, fault
        name = parse_name_in_attribute 'name', node
        soap_fault = Binding::SoapFault.new name
        soap_fault.use = fetch_attribute_value 'use', node
        fault.soap_fault = soap_fault
      end
    end
  end
end
