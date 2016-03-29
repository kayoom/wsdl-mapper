require 'wsdl_mapper/svc_generation/operation_generator_base'
require 'wsdl_mapper/dom/name'

module WsdlMapper
  module SvcGeneration
    class OperationS8rGenerator < OperationGeneratorBase
      include WsdlMapper::Dom

      SOAP_ENV_NS = 'http://schemas.xmlsoap.org/soap/envelope/'
      SOAP_BODY = Name.get SOAP_ENV_NS, 'Body'
      SOAP_HEADER = Name.get SOAP_ENV_NS, 'Header'

      def generate_operation_s8r(service, port, op, result)
        generate_op_input_s8r service, port, op, result
        generate_op_output_s8r service, port, op, result
      end

      def generate_op_input_s8r(service, port, op, result)
        modules = get_module_names service.name
        name = service_namer.get_input_s8r_name service.type, port.type, op.type

        type_file_for name, result do |f|
          f.requires input_s8r_base.require_path

          f.in_modules modules do
            in_classes f, service.name.class_name, port.name.class_name, op.name.class_name do
              generate_op_s8r_class f, port, op, name, op.type.input, input_s8r_base
            end
          end
        end
      end

      def generate_op_output_s8r(service, port, op, result)
        modules = get_module_names service.name
        name = service_namer.get_output_s8r_name service.type, port.type, op.type

        type_file_for name, result do |f|
          f.requires output_s8r_base.require_path

          f.in_modules modules do
            in_classes f, service.name.class_name, port.name.class_name, op.name.class_name do
              generate_op_s8r_class f, port, op, name, op.type.output, output_s8r_base
            end
          end
        end
      end

      def generate_op_s8r_class(f, port, op, name, in_out, base)
        f.in_sub_class name.class_name, base.name do
          generate_op_s8r_header f, port, op, in_out
          generate_op_s8r_body f, port, op, in_out
        end
      end

      def generate_op_s8r_header(f, port, op, in_out)
        headers = get_header_parts in_out
        f.in_def :build_header, 'x', 'header' do
          generate_each_header f, headers
        end
      end

      def generate_each_header(f, headers)
        headers.each do |header|
          part = header.header.part
          if header.header.use == 'encoded'
            generate_encoded_header f, header, part
          else #literal
            generate_literal_header f, header, part
          end
        end
      end

      def generate_literal_header(f, header, part)
        if part.element
          generate_literal_element_header f, header, part
        else
          generate_literal_type_header f, header, part
        end
      end

      def generate_literal_type_header(f, header, part)
        soap_header_wrapper f do
          get_and_build_header f, header, part.name
        end
      end

      def generate_literal_element_header(f, header, part)
        soap_header_wrapper f do
          get_and_build_header f, header, part.element.name
        end
      end

      def generate_encoded_header(f, header, part)
        soap_header_wrapper f do
          get_and_build_header f, header, part.name
        end
      end

      def get_and_build_header(f, header, element)
        type_name = namer.get_type_name(get_type_name(header.type)).name.inspect
        attr_name = header.property_name.attr_name
        element_name = generate_name element
        get_and_build f, type_name, 'header', attr_name, element_name
      end

      def generate_op_s8r_body(f, port, op, in_out)
        body_parts = get_body_parts in_out
        f.in_def :build_body, 'x', 'body' do
          generate_body f, port, op, body_parts, in_out
        end
      end

      def soap_header_wrapper(f, &block)
        f.block "x.complex(nil, #{generate_name(SOAP_HEADER)}, [])", ['x'], &block
      end

      def soap_body_wrapper(f, &block)
        f.block "x.complex(nil, #{generate_name(SOAP_BODY)}, [])", ['x'], &block
      end

      def part_wrapper(f, part, &block)
        f.block "x.complex(nil, #{generate_name(part.name)}, [])", ['x'], &block
      end

      def call_wrapper(f, op, suffix = '', &block)
        f.block "x.complex(nil, #{generate_name(op.name, suffix)}, [])", ['x'], &block
      end

      def generate_body(f, port, op, body_parts, in_out)
        if rpc?(port)
          if encoded?(in_out)
            generate_rpc_encoded_body f, op, in_out, body_parts
          else #literal
            generate_rpc_literal_body f, op, in_out, body_parts
          end
        else #document
          if encoded?(in_out)
            generate_doc_encoded_body f, body_parts
          else #literal
            generate_doc_literal_body f, body_parts
          end
        end
      end

      def encoded?(in_out)
        in_out.body.use == 'encoded'
      end

      def rpc?(port)
        port.type.binding.style == 'rpc'
      end

      def generate_doc_literal_body(f, body_parts)
        with_type = body_parts.first.part.element.nil?

        if with_type
          generate_doc_literal_type_body f, body_parts.first
        else
          generate_doc_literal_elements_body f, body_parts
        end
      end

      def generate_doc_literal_type_body(f, part)
        soap_body_wrapper f do
          get_and_build_body f, part, part.part.name
        end
      end

      def generate_doc_literal_elements_body(f, body_parts)
        soap_body_wrapper f do
          body_parts.each do |part|
            generate_doc_literal_elements_body_part f, part
          end
        end
      end

      def generate_doc_literal_elements_body_part(f, part)
        get_and_build_body f, part, part.part.element.name
      end

      def generate_doc_encoded_body(f, body_parts)
        soap_body_wrapper f do
          body_parts.each do |part|
            generate_encoded_body_part f, part
          end
        end
      end

      def generate_rpc_literal_body(f, op, in_out, body_parts)
        soap_body_wrapper f do
          suffix = in_out == op.type.output ? 'Response' : ''
          call_wrapper f, op.type, suffix do
            body_parts.each do |part|
              if part.part.element
                generate_rpc_literal_element_body_part f, part
              else
                generate_rpc_literal_type_body_part f, part
              end
            end
          end
        end
      end

      def generate_rpc_literal_type_body_part(f, part)
        get_and_build_body f, part, part.part.name
      end

      def generate_rpc_literal_element_body_part(f, part)
        get_and_build_body f, part, part.part.element.name
      end

      def generate_rpc_encoded_body(f, op, in_out, body_parts)
        soap_body_wrapper f do
          suffix = in_out == op.type.output ? 'Response' : ''
          call_wrapper f, op.type, suffix do
            body_parts.each do |part|
              generate_encoded_body_part f, part
            end
          end
        end
      end

      def generate_encoded_body_part(f, part)
        get_and_build_body f, part, part.part.name
      end

      def get_and_build_body(f, part, element)
        attr_name = part.property_name.attr_name
        element_name = generate_name element

        type_name = get_type_name part.type
        if WsdlMapper::Dom::BuiltinType.builtin?(type_name.name)
          build_simple f, part.type, 'body', attr_name, element_name
        else
          type_name = namer.get_type_name(get_type_name(part.type)).name.inspect
          get_and_build f, type_name, 'body', attr_name, element_name
        end
      end

      def build_simple(f, type, obj_name, attr_name, element_name)
        root_type = type.root.name.name
        f.block "x.simple(#{generate_name(type.name)}, #{element_name})", ['x'] do
          f.call 'x.text_builtin', "#{obj_name}.#{attr_name}", root_type.inspect
        end
      end

      def get_and_build(f, type_name, obj_name, attr_name, element_name)
        f.statement "x.get(#{type_name}).build(x, #{obj_name}.#{attr_name}, #{element_name})"
      end

      def input_s8r_base
        @input_s8r_base ||= @generator.runtime_base 'InputS8r', 'input_s8r'
      end

      def output_s8r_base
        @output_s8r_base ||= @generator.runtime_base 'OutputS8r', 'output_s8r'
      end
    end
  end
end
