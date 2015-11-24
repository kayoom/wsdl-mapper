require 'wsdl_mapper/svc_generation/service_generator'

module WsdlMapper
  module SvcGeneration
    class DocumentedServiceGenerator < ServiceGenerator
      def generate_service_port_accessors f, ports
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        ports.map do |p|
          attr_name = p.property_name.attr_name
          type = p.name.name
          yard.attribute! attr_name, type, nil do
            yard.tag :soap_name, p.type.name.name
            yard.tag :soap_binding, p.type.binding_name.name
          end
          f.attr_readers attr_name
        end
      end
    end
  end
end
