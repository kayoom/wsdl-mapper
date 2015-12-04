require 'wsdl_mapper/svc_generation/port_generator'

module WsdlMapper
  module SvcGeneration
    class DocumentedPortGenerator < PortGenerator
      def generate_port_operation_accessors(f, ops)
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        ops.map do |op|
          attr_name = op.property_name.attr_name
          type = op.name.name
          yard.attribute! attr_name, type, nil do
            yard.tag :soap_name, op.type.name.name
          end
          f.attr_readers attr_name
        end
      end
    end
  end
end
