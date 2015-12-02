require 'wsdl_mapper/svc_generation/operation_generator_base'
require 'wsdl_mapper/dom/name'

module WsdlMapper
  module SvcGeneration
    class OperationD10rGenerator < OperationGeneratorBase
      include WsdlMapper::Dom

      SOAP_ENV_NS = 'http://www.w3.org/2001/12/soap-envelope'
      SOAP_BODY = Name.get SOAP_ENV_NS, 'Body'
      SOAP_HEADER = Name.get SOAP_ENV_NS, 'Header'

      def generate_operation_d10r service, port, op, result
        # generate_op_input_d10r service, port, op, result
        generate_op_output_d10r service, port, op, result
      end

      def generate_op_output_d10r service, port, op, result
        modules = get_module_names service.name
        name = service_namer.get_output_d10r_name service.type, port.type, op.type

        type_file_for name, result do |f|
          f.requires output_d10r_base.require_path

          f.in_modules modules do
            in_classes f, service.name.class_name, port.name.class_name, op.name.class_name do
              generate_op_d10r_class f, port, op, name, op.type.output, output_d10r_base
            end
          end
        end
      end

      def generate_op_d10r_class f, port, op, name, in_out, base
        f.in_sub_class name.class_name, base.name do
        end
      end

      #   def generate_op_output_d10r service, port, op, result
    #     modules = get_module_names service.name
    #     name = service_namer.get_output_d10r_name service.type, port.type, op.type
    #
    #     type_file_for name, result do |f|
    #       f.requires output_d10r_base.require_path
    #
    #       f.in_modules modules do
    #         in_classes f, service.name.class_name, port.name.class_name, op.name.class_name do
    #           generate_op_d10r_class f, port, op, name, op.type.output, output_d10r_base
    #         end
    #       end
    #     end
    #   end
    #
    #   def generate_op_d10r_class f, port, op, name, in_out, base
    #     f.in_sub_class name.class_name, base.name do
    #       generate_op_d10r_header f, port, op, in_out
    #       generate_op_d10r_body f, port, op, in_out
    #     end
    #   end
    #
    #   def generate_op_d10r_header f, port, op, in_out
    #     headers = get_header_parts in_out
    #     f.in_def :build_header, 'x', 'header' do
    #       generate_each_header f, headers
    #     end
    #   end
    #
    #   def generate_each_header f, headers
    #     headers.each do |header|
    #       part = header.header.part
    #       if header.header.use == 'encoded'
    #         generate_encoded_header f, header, part
    #       else #literal
    #         generate_literal_header f, header, part
    #       end
    #     end
    #   end
    #
    #   def generate_literal_header f, header, part
    #     if part.element
    #       generate_literal_element_header f, header, part
    #     else
    #       generate_literal_type_header f, header
    #     end
    #   end
    #
    #   def generate_literal_type_header f, header
    #     get_and_build_header f, header, SOAP_HEADER
    #   end
    #
    #   def generate_literal_element_header f, header, part
    #     soap_header_wrapper f do
    #       part_wrapper f, part do
    #         get_and_build_header f, header, part.element.name
    #       end
    #     end
    #   end
    #
    #   def generate_encoded_header f, header, part
    #     soap_header_wrapper f do
    #       get_and_build_header f, header, part.name
    #     end
    #   end
    #
    #   def get_and_build_header f, header, element
    #     type_name = get_type_name(header.type).name.inspect
    #     attr_name = header.property_name.attr_name
    #     element_name = generate_name element
    #     get_and_build f, type_name, 'header', attr_name, element_name
    #   end
    #
    #   def generate_op_d10r_body f, port, op, in_out
    #     body_parts = get_body_parts in_out
    #     f.in_def :build_body, 'x', 'body' do
    #       generate_body f, port, op, body_parts, in_out
    #     end
    #   end
    #
    #   def soap_header_wrapper f, &block
    #     f.block "x.complex(nil, #{generate_name(SOAP_HEADER)}, [])", ['x'], &block
    #   end
    #
    #   def soap_body_wrapper f, &block
    #     f.block "x.complex(nil, #{generate_name(SOAP_BODY)}, [])", ['x'], &block
    #   end
    #
    #   def part_wrapper f, part, &block
    #     f.block "x.complex(nil, #{generate_name(part.name)}, [])", ['x'], &block
    #   end
    #
    #   def call_wrapper f, op, &block
    #     f.block "x.complex(nil, #{generate_name(op.name)}, [])", ['x'], &block
    #   end
    #
    #   def generate_body f, port, op, body_parts, in_out
    #     if rpc?(port)
    #       if encoded?(in_out)
    #         generate_rpc_encoded_body f, op, body_parts
    #       else #literal
    #         generate_rpc_literal_body f, op, body_parts
    #       end
    #     else #document
    #       if encoded?(in_out)
    #         generate_doc_encoded_body f, body_parts
    #       else #literal
    #         generate_doc_literal_body f, body_parts
    #       end
    #     end
    #   end
    #
    #   def encoded? in_out
    #     in_out.body.use == 'encoded'
    #   end
    #
    #   def rpc? port
    #     port.type.binding.style == 'rpc'
    #   end
    #
    #   def generate_doc_literal_body f, body_parts
    #     with_type = body_parts.first.part.element.nil?
    #
    #     if with_type
    #       generate_doc_literal_type_body f, body_parts.first
    #     else
    #       generate_doc_literal_elements_body f, body_parts
    #     end
    #   end
    #
    #   def generate_doc_literal_type_body f, part
    #     get_and_build_body f, part, SOAP_BODY
    #   end
    #
    #   def generate_doc_literal_elements_body f, body_parts
    #     soap_body_wrapper f do
    #       body_parts.each do |part|
    #         generate_doc_literal_elements_body_part f, part
    #       end
    #     end
    #   end
    #
    #   def generate_doc_literal_elements_body_part f, part
    #     get_and_build_body f, part, part.part.element.name
    #   end
    #
    #   def generate_doc_encoded_body f, body_parts
    #     soap_body_wrapper f do
    #       body_parts.each do |part|
    #         generate_encoded_body_part f, part
    #       end
    #     end
    #   end
    #
    #   def generate_rpc_literal_body f, op, body_parts
    #     soap_body_wrapper f do
    #       call_wrapper f, op.type do
    #         body_parts.each do |part|
    #           if part.part.element
    #             generate_rpc_literal_element_body_part f, part
    #           else
    #             generate_rpc_literal_type_body_part f, part
    #           end
    #         end
    #       end
    #     end
    #   end
    #
    #   def generate_rpc_literal_type_body_part f, part
    #     get_and_build_body f, part, part.part.name
    #   end
    #
    #   def generate_rpc_literal_element_body_part f, part
    #     part_wrapper f, part.part do
    #       get_and_build_body f, part, part.part.element.name
    #     end
    #   end
    #
    #   def generate_rpc_encoded_body f, op, body_parts
    #     soap_body_wrapper f do
    #       call_wrapper f, op.type do
    #         body_parts.each do |part|
    #           generate_encoded_body_part f, part
    #         end
    #       end
    #     end
    #   end
    #
    #   def generate_encoded_body_part f, part
    #     get_and_build_body f, part, part.part.name
    #   end
    #
    #   def get_and_build_body f, part, element
    #     type_name = get_type_name(part.type).name.inspect
    #     attr_name = part.property_name.attr_name
    #     element_name = generate_name element
    #     get_and_build f, type_name, 'body', attr_name, element_name
    #   end
    #
    #   def get_and_build f, type_name, obj_name, attr_name, element_name
    #     f.statement "x.get(#{type_name}).build(x, #{obj_name}.#{attr_name}, #{element_name})"
    #   end
    #
      def input_d10r_base
        @input_d10r_base ||= @generator.runtime_base 'InputD10r', 'input_d10r'
      end

      def output_d10r_base
        @output_d10r_base ||= @generator.runtime_base 'OutputD10r', 'output_d10r'
      end
    end
  end
end
