require 'wsdl_mapper/svc_generation/operation_generator_base'
require 'wsdl_mapper/dom/name'

module WsdlMapper
  module SvcGeneration
    class OperationD10rGenerator < OperationGeneratorBase
      include WsdlMapper::Dom

      SOAP_ENV_NS = 'http://schemas.xmlsoap.org/soap/envelope/'
      SOAP_BODY = Name.get SOAP_ENV_NS, 'Body'
      SOAP_HEADER = Name.get SOAP_ENV_NS, 'Header'

      def initialize generator
        super generator
        @schema_type_directory_name = namer.get_d10r_type_directory_name
        @schema_element_directory_name = namer.get_d10r_element_directory_name
      end

      def generate_operation_d10r service, port, op, result
        generate_op_input_d10r service, port, op, result
        generate_op_output_d10r service, port, op, result
      end

      def generate_op_input_d10r service, port, op, result
        name = service_namer.get_input_d10r_name service.type, port.type, op.type

        type_directory_name = service_namer.get_input_type_directory_name
        header_d10r_name = service_namer.get_input_header_d10r_name
        body_d10r_name = service_namer.get_input_body_d10r_name
        header_name = service_namer.get_input_header_name service.type, port.type, op.type
        body_name = service_namer.get_input_body_name service.type, port.type, op.type
        element_directory_name = service_namer.get_input_element_directory_name

        generate_op_d10r service, port, op, name, op.type.input,
          header_name, header_d10r_name, body_name, body_d10r_name, type_directory_name, element_directory_name, result
      end

      def generate_op_output_d10r service, port, op, result
        name = service_namer.get_output_d10r_name service.type, port.type, op.type

        type_directory_name = service_namer.get_output_type_directory_name
        header_d10r_name = service_namer.get_output_header_d10r_name
        body_d10r_name = service_namer.get_output_body_d10r_name
        header_name = service_namer.get_output_header_name service.type, port.type, op.type
        body_name = service_namer.get_output_body_name service.type, port.type, op.type
        element_directory_name = service_namer.get_output_element_directory_name

        generate_op_d10r service, port, op, name, op.type.output,
          header_name, header_d10r_name, body_name, body_d10r_name, type_directory_name, element_directory_name, result
      end

      def generate_op_d10r service, port, op, name, in_out,
          header_name, header_d10r_name, body_name, body_d10r_name,
          type_directory_name, element_directory_name, result
        modules = get_module_names service.name
        type_file_for name, result do |f|
          f.requires envelope_type.require_path,
            type_directory_base.require_path,
            element_directory_base.require_path,
            deserializer_type.require_path,
            soap_type_directory.require_path,
            soap_element_directory.require_path,
            @schema_type_directory_name.require_path,
            @schema_element_directory_name.require_path,
            header_name.require_path,
            body_name.require_path

          f.in_modules modules do
            in_classes f, service.name.class_name, port.name.class_name, op.name.class_name do
              generate_type_directory f, type_directory_name
              generate_header_d10r f, header_d10r_name, type_directory_name, header_name, in_out
              generate_body_d10r f, body_d10r_name, type_directory_name, body_name, port, op, in_out
              generate_element_directory f, element_directory_name, type_directory_name
              generate_d10r f, name, element_directory_name
            end
          end
        end
      end

      def generate_d10r f, input_d10r_name, element_directory_name
        f.assignment input_d10r_name.class_name, "#{deserializer_type.name}.new(#{element_directory_name})"
      end

      def generate_element_directory f, element_directory_name, type_directory_name
        f.assignment element_directory_name, "#{element_directory_base.name}.new(#{type_directory_name}, #{@schema_element_directory_name.name}, #{soap_element_directory.name})"
      end

      def generate_body_d10r f, body_deserializer_name, type_directory_name, input_body_name, port, op, in_out
        parts = get_body_parts in_out
        f.block "#{body_deserializer_name} = #{type_directory_name}.register_type(#{generate_name(SOAP_BODY)}, #{input_body_name.name})", [] do
          op_name = get_op_name op.type, in_out
          if port.type.binding.style == 'rpc'
            f.call :register_wrapper, generate_name(op_name)
          end
          parts.each do |part|
            name = get_type_name(part.type).name
            element_name = if port.type.binding.style == 'rpc'
              part.part.name
            else
              if part.part.element
                part.part.element.name
              else
                part.part.name
              end
            end
            f.call :register_prop, ":#{part.property_name.attr_name}", generate_name(element_name), generate_name(name)
          end
        end
      end

      def get_op_name op, in_out
        if in_out == op.input
          op.name
        else
          WsdlMapper::Dom::Name.get op.name.ns, "#{op.name.name}Response"
        end
      end

      def generate_header_d10r f, header_deserializer_name, type_directory_name, input_header_name, in_out
        parts = get_header_parts in_out
        f.block "#{header_deserializer_name} = #{type_directory_name}.register_type(#{generate_name(SOAP_HEADER)}, #{input_header_name.name})", [] do
          parts.each do |part|
            name = get_type_name(part.type).name
            f.call :register_prop, ":#{part.property_name.attr_name}", generate_name(part.header.part.name), generate_name(name)
          end
        end
      end

      def generate_type_directory f, type_directory_name
        f.assignment type_directory_name, "#{type_directory_base.name}.new(#{@schema_type_directory_name.name}, #{soap_type_directory.name})"
      end

      def type_directory_base
        @type_directory_base ||= WsdlMapper::Naming::TypeName.new 'TypeDirectory', %w[WsdlMapper Deserializers], 'type_directory.rb', %w[wsdl_mapper deserializers]
      end

      def element_directory_base
        @element_directory_base ||= WsdlMapper::Naming::TypeName.new 'ElementDirectory', %w[WsdlMapper Deserializers], 'element_directory.rb', %w[wsdl_mapper deserializers]
      end

      def soap_type_directory
        @soap_type_directory ||= WsdlMapper::Naming::TypeName.new 'SoapTypeDirectory', %w[WsdlMapper SvcDesc], 'soap_type_directory.rb', %w[wsdl_mapper svc_desc]
      end

      def soap_element_directory
        @soap_element_directory ||= WsdlMapper::Naming::TypeName.new 'SoapElementDirectory', %w[WsdlMapper SvcDesc], 'soap_element_directory.rb', %w[wsdl_mapper svc_desc]
      end

      def deserializer_type
        @deserializer_type ||= WsdlMapper::Naming::TypeName.new 'LazyLoadingDeserializer', %w[WsdlMapper Deserializers], 'lazy_loading_deserializer.rb', %w[wsdl_mapper deserializers]
      end

      def envelope_type
        @envelope_type ||= WsdlMapper::Naming::TypeName.new 'Envelope', %w[WsdlMapper SvcDesc], 'envelope.rb', %w[wsdl_mapper svc_desc]
      end
    end
  end
end
