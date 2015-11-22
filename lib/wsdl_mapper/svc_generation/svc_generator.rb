require 'wsdl_mapper/generation/base'
require 'wsdl_mapper/generation/type_to_generate'

require 'wsdl_mapper/generation/default_formatter'
require 'wsdl_mapper/generation/result'
require 'wsdl_mapper/naming/type_name'
require 'wsdl_mapper/naming/default_service_namer'

module WsdlMapper
  module SvcGeneration
    class SvcGenerator < WsdlMapper::Generation::Base
      include WsdlMapper::Generation

      class ServiceToGenerate < Struct.new(:type, :name, :property_name)
      end

      def initialize context,
          formatter_factory: DefaultFormatter, namer: WsdlMapper::Naming::DefaultServiceNamer.new
        @formatter_factory = formatter_factory
        @context = context
        @namer = namer
      end

      def generate desc
        result = Result.new description: desc

        generate_api desc, result

        result
      end

      def get_formatter io
        @formatter_factory.new io
      end

      protected
      def generate_api desc, result
        name = @namer.get_api_name
        modules = get_module_names name
        services = desc.each_service.map do |service|
          ServiceToGenerate.new service, @namer.get_service_name(service), @namer.get_property_name(service)
        end

        services.each do |service|
          generate_service service, result
        end

        type_file_for name, result do |f|
          f.requires api_base.require_path
          f.requires *services.map { |s| s.name.require_path }

          f.in_modules modules do
            f.in_sub_class name.class_name, api_base.name do
              f.attr_readers *services.map { |s| s.property_name.attr_name }
              f.in_def :initialize, 'options = {}' do
                f.call :super, 'options'
                services.each do |s|
                  f.assignment s.property_name.var_name, "#{s.name.name}.new(self)"
                end
              end
            end
          end
        end
      end

      def generate_service service, result
        modules = get_module_names service.name
        ports = service.type.each_port.map do |port|
          ServiceToGenerate.new port, @namer.get_port_name(service.type, port), @namer.get_property_name(port)
        end

        ports.each do |port|
          generate_port service, port, result
        end

        type_file_for service.name, result do |f|
          f.requires service_base.require_path

          f.in_modules modules do
            f.in_sub_class service.name.class_name, service_base.name do
              f.requires *ports.map { |p| p.name.require_path }
              f.attr_readers *ports.map { |p| p.property_name.attr_name }
              f.in_def :initialize, 'api' do
                f.call :super, 'api'
                ports.each do |p|
                  f.assignment p.property_name.var_name, "#{p.name.name}.new(api, self)"
                end
              end
            end
          end
        end
      end

      def generate_port service, port, result
        modules = get_module_names service.name
        ops = port.type.binding.each_operation.map do |op|
          ServiceToGenerate.new op, @namer.get_operation_name(service.type, port.type, op), @namer.get_property_name(op)
        end

        ops.each do |op|
          generate_op service, port, op, result
        end

        type_file_for port.name, result do |f|
          f.requires port_base.require_path

          f.in_modules modules do
            f.in_class service.name.class_name do
              f.in_sub_class port.name.class_name, port_base.name do
                f.requires *ops.map { |o| o.name.require_path }
                f.assignments ['SOAP_ADDRESS', port.type.address_location.inspect]
                f.in_def :initialize, 'api', 'service' do
                  f.call :super, 'api', 'service'
                  ops.each do |o|
                    f.assignment o.property_name.var_name, "#{o.name.name}.new(api, service, self)"
                  end
                end
              end
            end
          end
        end
      end

      def generate_op service, port, op, result
        modules = get_module_names service.name

        type_file_for op.name, result do |f|
          f.requires operation_base.require_path

          f.in_modules modules do
            f.in_class service.name.class_name do
              f.in_class port.name.class_name do
                f.in_sub_class op.name.class_name, operation_base.name do
                  f.assignments ['SOAP_ACTION', op.type.soap_action.inspect]
                  f.in_def :initialize, 'api', 'service', 'port' do
                    f.call :super, 'api', 'service', 'port'
                  end
                end
              end
            end
          end
        end
      end

      def api_base
        @api_base ||= runtime_base 'Api', 'api'
      end

      def service_base
        @service_base ||= runtime_base 'Service', 'service'
      end

      def port_base
        @port_base ||= runtime_base 'Port', 'port'
      end

      def operation_base
        @operation_base ||= runtime_base 'OperationFactory', 'operation_factory'
      end

      def runtime_base name, file_name
        WsdlMapper::Naming::TypeName.new name, runtime_modules, "#{file_name}.rb", runtime_path
      end

      def runtime_modules
        @runtime_modules ||= %w[WsdlMapper Runtime]
      end

      def runtime_path
        @runtime_path ||= %w[wsdl_mapper runtime]
      end
    end
  end
end
