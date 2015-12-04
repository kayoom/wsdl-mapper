require 'wsdl_mapper/svc_generation/generator_base'

module WsdlMapper
  module SvcGeneration
    class ServiceGenerator < GeneratorBase

      def generate_service service, result
        modules = get_module_names service.name
        ports = service.type.each_port.map do |port|
          TypeToGenerate.new port, service_namer.get_port_name(service.type, port), service_namer.get_property_name(port)
        end

        ports.each do |port|
          port_generator.generate_port service, port, result
        end

        type_file_for service.name, result do |f|
          f.requires service_base.require_path

          f.in_modules modules do
            generate_service_class f, ports, service
          end
        end
      end

      def generate_service_class f, ports, service
        f.in_sub_class service.name.class_name, service_base.name do
          f.requires *ports.map { |p| p.name.require_path }
          generate_service_port_accessors f, ports
          generate_service_ctr f, ports
        end
      end

      def generate_service_port_accessors f, ports
        f.attr_readers *ports.map { |p| p.property_name.attr_name }
      end

      def generate_service_ctr f, ports
        f.in_def :initialize, 'api' do
          f.call :super, 'api'
          ports.each do |p|
            f.assignment p.property_name.var_name, "#{p.name.name}.new(api, self)"
            f.statement "@_ports << #{p.property_name.var_name}"
          end
        end
      end
    end
  end
end
