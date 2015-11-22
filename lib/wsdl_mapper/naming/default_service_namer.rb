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

      #
      # # @param [WsdlMapper::Dom::ComplexType, WsdlMapper::Dom::SimpleType] type
      # # @return [TypeName]
      # def get_type_name type
      #   type_name = TypeName.new get_class_name(type), get_class_module_path(type), get_class_file_name(type), get_class_file_path(type)
      #   type_name.parent = make_parents get_class_module_path(type)
      #   type_name
      # end

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
        name = "#{operation.name.name}Factory"
        type_name = TypeName.new camelize(name), module_path, get_file_name(name), get_file_path(module_path)
        type_name.parent = make_parents module_path
        type_name
      end
    end
  end
end
