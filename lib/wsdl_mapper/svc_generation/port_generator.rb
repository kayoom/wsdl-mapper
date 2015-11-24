require 'wsdl_mapper/svc_generation/generator_base'

module WsdlMapper
  module SvcGeneration
    class PortGenerator < GeneratorBase
      def generate_port service, port, result
        modules = get_module_names service.name
        ops = port.type.binding.each_operation.map do |op|
          TypeToGenerate.new op, service_namer.get_operation_name(service.type, port.type, op), service_namer.get_property_name(op)
        end

        ops.each do |op|
          operation_generator.generate_operation service, port, op, result
        end

        type_file_for port.name, result do |f|
          f.requires port_base.require_path

          f.in_modules modules do
            f.in_class service.name.class_name do
              generate_port_class f, ops, port
            end
          end
        end
      end

      def generate_port_class f, ops, port
        f.in_sub_class port.name.class_name, port_base.name do
          f.requires *ops.map { |op| op.name.require_path }
          generate_port_operation_accessors f, ops
          generate_port_ctr f, ops, port
        end
      end

      def generate_port_ctr f, ops, port
        f.in_def :initialize, 'api', 'service' do
          f.call :super, 'api', 'service'
          f.assignment '@style', port.type.binding.style.inspect
          f.assignment '@transport', port.type.binding.transport.inspect
          f.assignment '@soap_address', port.type.address_location.inspect

          ops.each do |op|
            f.assignment op.property_name.var_name, op.name.name + '.new(api, service, self)'
          end
        end
      end

      def generate_port_operation_accessors f, ops
        f.attr_readers *ops.map { |op| op.property_name.attr_name }
      end
    end
  end
end
