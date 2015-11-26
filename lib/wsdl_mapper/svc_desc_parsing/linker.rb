require 'wsdl_mapper/dom_parsing/linker'
require 'wsdl_mapper/dom/schema'

module WsdlMapper
  module SvcDescParsing
    # The Linker creates pointers between the different components of a WSDL schema,
    # e.g. links service.port -> binding, portType
    class Linker

      # @param [WsdlMapper::SvcDesc::Wsdl11::Description] description
      def initialize description
        @description = description
      end

      def link
        schema = WsdlMapper::Dom::Schema.new
        @description.each_schema do |s|
          schema.add_import s.target_namespace, s
        end
        schema_linker = WsdlMapper::DomParsing::Linker.new schema
        schema_linker.link

        link_messages
        link_port_types
        link_bindings
        link_services

        @description
      end

      private
      def link_bindings
        @description.each_binding do |b|
          b.type = @description.get_port_type b.type_name

          b.each_operation do |op|
            link_binding_operation b, op
          end
        end
      end

      def link_binding_operation b, op
        op.target = b.type.find_operation op.name, op.input.name, op.output.name

        link_binding_operation_input op
        link_binding_operation_output op
        link_binding_operation_faults op
      end

      def link_binding_operation_faults op
        op.each_fault do |fault|
          fault.target = op.target.get_fault fault.name
        end
      end

      def link_binding_operation_output op
        op.output.target = op.target.output
        op.output.message = op.target.output.message
        op.output.each_header do |header|
          if header.message_name
            header.message = @description.get_message header.message_name
            header.part = header.message.get_part header.part_name
          end
          header.each_header_fault do |header_fault|
            header_fault.message = @description.get_message header_fault.message_name
            header_fault.part = header_fault.message.get_part header_fault.part_name
          end
        end
        op.output.body.parts = op.output.body.part_names.map do |pn|
          op.output.message.get_part pn
        end
      end

      def link_binding_operation_input op
        op.input.target = op.target.input
        op.input.message = op.target.input.message
        op.input.each_header do |header|
          if header.message_name
            header.message = @description.get_message header.message_name
            header.part = header.message.get_part header.part_name
          end
          header.each_header_fault do |header_fault|
            header_fault.message = @description.get_message header_fault.message_name
            header_fault.part = header_fault.message.get_part header_fault.part_name
          end
        end
        op.input.body.parts = op.input.body.part_names.map do |pn|
          op.input.message.get_part pn
        end
      end

      def link_services
        @description.each_service do |svc|
          svc.each_port do |p|
            p.binding = @description.get_binding p.binding_name
          end
        end
      end

      def link_port_types
        @description.each_port_type do |pt|
          pt.each_operation do |op|
            op.input.message = @description.get_message op.input.message_name
            op.output.message = @description.get_message op.output.message_name

            op.each_fault do |fault|
              fault.message = @description.get_message fault.message_name
            end
          end
        end
      end

      def link_messages
        @description.each_message do |msg|
          msg.each_part do |part|
            if part.element_name
              part.element = @description.get_element part.element_name
            elsif part.type_name
              part.type = @description.get_type part.type_name
            end
          end
        end
      end
    end
  end
end
