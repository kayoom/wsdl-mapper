require 'wsdl_mapper/dom/name'

require 'wsdl_mapper/naming/type_name'
require 'wsdl_mapper/naming/property_name'
require 'wsdl_mapper/naming/inflector'

require 'wsdl_mapper/naming/namer_base'

module WsdlMapper
  module Naming
    class DefaultServiceNamer < NamerBase

      def initialize module_path: [], api_name: 'Api'
        super module_path: module_path
        @api_name = api_name
      end

      def get_api_name
        type_name = TypeName.new camelize(@api_name), @module_path, get_file_name(@api_name), get_file_path(@module_path)
        type_name.parent = make_parents @module_path
        type_name
      end

      def get_service_name service
        type_name = TypeName.new camelize(service.name.name), @module_path, get_file_name(service.name.name), get_file_path(@module_path)
        type_name.parent = make_parents @module_path
        type_name
      end

      def get_property_name type
        PropertyName.new underscore(type.name.name), '@' + underscore(type.name.name)
      end

      def get_port_name service, port
        service_name = get_service_name service
        module_path = @module_path + [service_name.class_name]
        type_name = TypeName.new camelize(port.name.name), module_path, get_file_name(port.name.name), get_file_path(module_path)
        type_name.parent = make_parents module_path
        type_name
      end

      def get_operation_name service, port, operation
        service_name = get_service_name service
        port_name = get_port_name service, port
        module_path = @module_path + [service_name.class_name, port_name.class_name]
        name = operation.name.name
        type_name = TypeName.new camelize(name), module_path, get_file_name(name), get_file_path(module_path)
        type_name.parent = make_parents module_path
        type_name
      end

      def get_operation_s8r_name service, port, operation
        service_name = get_service_name service
        port_name = get_port_name service, port
        module_path = @module_path + [service_name.class_name, port_name.class_name]
        name = operation.name.name + "S8r"
        type_name = TypeName.new camelize(name), module_path, get_file_name(name), get_file_path(module_path)
        type_name.parent = make_parents module_path
        type_name
      end

      def get_property_name_for_string str
        PropertyName.new underscore(str), '@' + underscore(str)
      end

      def get_input_body_name service, port, op
        get_body_name service, port, op, 'InputBody'
      end

      def get_body_name service, port, op, name
        service_name = get_service_name service
        port_name = get_port_name service, port
        op_name = get_operation_name service, port, op
        module_path = @module_path + [service_name.class_name, port_name.class_name, op_name.class_name]
        type_name = TypeName.new camelize(name), module_path, get_file_name(name), get_file_path(module_path)
        type_name.parent = make_parents module_path
        type_name
      end
      alias_method :get_header_name, :get_body_name

      def get_output_body_name service, port, op
        get_body_name service, port, op, 'OutputBody'
      end

      def get_input_header_name service, port, op
        get_header_name service, port, op, 'InputHeader'
      end

      def get_output_header_name service, port, op
        get_header_name service, port, op, 'OutputHeader'
      end

      def get_header_property_name message_name, part_name
        name = message_name.name + part_name.name
        PropertyName.new underscore(name), '@' + underscore(name)
      end

      def get_body_property_name part_name
        PropertyName.new underscore(part_name.name), '@' + underscore(part_name.name)
      end
    end
  end
end
