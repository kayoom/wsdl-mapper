require 'wsdl_mapper/svc_generation/operation_generator'
require 'wsdl_mapper/generation/yard_doc_formatter'

module WsdlMapper
  module SvcGeneration
    class DocumentedOperationGenerator < OperationGenerator
      def generate_header_accessors(f, parts)
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        parts.each do |p|
          attr_name = p.property_name.attr_name
          type = p.name.name
          yard.attribute! attr_name, type, nil
          f.attr_accessors p.property_name.attr_name
        end
      end

      def generate_new_input(f, service, port, op)
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        header_name = service_namer.get_input_header_name(service.type, port.type, op.type)
        body_name = service_namer.get_input_body_name(service.type, port.type, op.type)
        f.blank_line
        generate_new_documentation body_name, header_name, yard
        super
      end

      def generate_new_output(f, service, port, op)
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        header_name = service_namer.get_output_header_name(service.type, port.type, op.type)
        body_name = service_namer.get_output_body_name(service.type, port.type, op.type)
        f.blank_line
        generate_new_documentation body_name, header_name, yard
        super
      end

      def generate_input_s8r(f, service, port, op)
        f.blank_line
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        name = service_namer.get_input_s8r_name(service.type, port.type, op.type).name
        yard.type_tag :return, name, 'The input serializer'
        yard.blank_line
        super
      end

      def generate_new_documentation(body_name, header_name, yard)
        yard.params [:header, '::Hash', "Keyword arguments for {#{header_name.name}.new}"],
         [:body, '::Hash', "Keyword arguments for {#{body_name.name}.new}"]
        yard.type_tag :return, @generator.runtime_base('Message', 'message').name, 'A new SOAP message'
        yard.blank_line
      end

      def generate_output_s8r(f, service, port, op)
        f.blank_line
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        name = service_namer.get_output_s8r_name(service.type, port.type, op.type).name
        yard.type_tag :return, name, 'The output serializer'
        yard.blank_line
        super
      end

      def generate_input_d10r(f, service, port, op)
        f.blank_line
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        name = service_namer.get_input_d10r_name(service.type, port.type, op.type).name
        yard.type_tag :return, name, 'The input deserializer'
        yard.blank_line
        super
      end

      def generate_output_d10r(f, service, port, op)
        f.blank_line
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        name = service_namer.get_output_d10r_name(service.type, port.type, op.type).name
        yard.type_tag :return, name, 'The output deserializer'
        yard.blank_line
        super
      end

      def generate_accessors(f, parts)
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        parts.each do |p|
          attr_name = p.property_name.attr_name
          type = @generator.get_ruby_type_name p.type

          yard.attribute! attr_name, type, '' do
          end
          f.attr_accessors attr_name
        end
      end

      def generate_ctr(f, parts)
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        f.blank_line
        params = parts.map do |p|
          attr_name = p.property_name.attr_name
          type = @generator.get_ruby_type_name p.type

          [attr_name, type, '']
        end
        yard.params(*params)
        super
      end
    end
  end
end
