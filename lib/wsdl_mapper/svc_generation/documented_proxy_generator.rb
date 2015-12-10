require 'wsdl_mapper/svc_generation/proxy_generator'

module WsdlMapper
  module SvcGeneration
    class DocumentedProxyGenerator < ProxyGenerator

      def generate_operation(f, op)
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        f.blank_line
        yard.text op.type.name.name
        yard.blank_line
        yard.tag :xml_name, op.type.name.name
        yard.tag :xml_namespace, op.type.name.ns
        yard.param :body, '::Hash', 'Keyword arguments for the InputBody constructor'
        get_body_parts(op.type.input).each do |part|
          type = @generator.get_ruby_type_name part.type
          yard.option :body, type, part.property_name.attr_name
        end
        yard.blank_line
        super
      end
    end
  end
end
