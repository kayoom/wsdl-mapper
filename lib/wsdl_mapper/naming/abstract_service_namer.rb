module WsdlMapper
  module Naming
    # @abstract
    class AbstractServiceNamer
      def get_api_name
        raise NotImplementedError
      end

      def get_service_name(service)
        raise NotImplementedError
      end

      def get_property_name(type)
        raise NotImplementedError
      end

      def get_port_name(service, port)
        raise NotImplementedError
      end

      def get_proxy_name(service, port)
        raise NotImplementedError
      end

      def get_operation_name(service, port, operation)
        raise NotImplementedError
      end

      def get_input_body_name(service, port, op)
        raise NotImplementedError
      end

      def get_input_s8r_name(service, port, op)
        raise NotImplementedError
      end

      def get_output_s8r_name(service, port, op)
        raise NotImplementedError
      end

      def get_input_d10r_name(service, port, op)
        raise NotImplementedError
      end

      def get_output_d10r_name(service, port, op)
        raise NotImplementedError
      end

      def get_output_type_directory_name
        raise NotImplementedError
      end

      def get_output_header_d10r_name
        raise NotImplementedError
      end

      def get_output_body_d10r_name
        raise NotImplementedError
      end

      def get_output_element_directory_name
        raise NotImplementedError
      end

      def get_input_type_directory_name
        raise NotImplementedError
      end

      def get_input_header_d10r_name
        raise NotImplementedError
      end

      def get_input_body_d10r_name
        raise NotImplementedError
      end

      def get_input_element_directory_name
        raise NotImplementedError
      end

      def get_operation_part_name(service, port, op, name)
        raise NotImplementedError
      end

      def get_header_name(service, port, op, name)
        raise NotImplementedError
      end

      def get_body_name(service, port, op, name)
        raise NotImplementedError
      end

      def get_output_body_name(service, port, op)
        raise NotImplementedError
      end

      def get_input_header_name(service, port, op)
        raise NotImplementedError
      end

      def get_output_header_name(service, port, op)
        raise NotImplementedError
      end

      def get_header_property_name(message_name, part_name)
        raise NotImplementedError
      end

      def get_body_property_name(part_name)
        raise NotImplementedError
      end
    end
  end
end
