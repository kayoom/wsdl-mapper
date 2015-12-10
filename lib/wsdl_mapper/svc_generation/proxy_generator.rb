require 'wsdl_mapper/svc_generation/generator_base'

module WsdlMapper
  module SvcGeneration
    class ProxyGenerator < GeneratorBase
      def generate_proxy(service, port, ops, result)
        modules = get_module_names service.name
        proxy_name = service_namer.get_proxy_name(service.type, port.type)

        type_file_for proxy_name, result do |f|
          f.requires proxy_base.require_path,
            port.name.require_path

          f.in_modules modules do
            f.in_class service.name.class_name do
              generate_proxy_class f, ops, proxy_name, port
            end
          end
        end
      end

      def generate_proxy_class(f, ops, proxy_name, port)
        f.in_sub_class proxy_name.class_name, proxy_base.name do
          ops.each do |op|
            generate_operation f, op
          end
        end
      end

      def generate_operation(f, op)
        name = op.property_name.attr_name
        f.in_def name, ['body', '**args'] do
          f.call '@_api._call', "@_port.#{name}", 'body', '**args'
        end
      end
    end
  end
end
