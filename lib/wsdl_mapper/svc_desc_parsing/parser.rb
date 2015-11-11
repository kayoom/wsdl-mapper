require 'wsdl_mapper/parsing/base'
require 'wsdl_mapper/dom/namespaces'
require 'wsdl_mapper/svc_desc/wsdl11/description'
require 'wsdl_mapper/svc_desc_parsing/wsdl11'
require 'wsdl_mapper/svc_desc_parsing/soap'
require 'wsdl_mapper/svc_desc_parsing/soap_enc'

require 'wsdl_mapper/svc_desc_parsing/message_parser'
require 'wsdl_mapper/svc_desc_parsing/port_type_parser'
require 'wsdl_mapper/svc_desc_parsing/service_parser'
require 'wsdl_mapper/svc_desc_parsing/binding_parser'
require 'wsdl_mapper/svc_desc_parsing/types_parser'

module WsdlMapper
  module SvcDescParsing
    class Parser < WsdlMapper::Parsing::Base
      include WsdlMapper::SvcDescParsing::Wsdl11

      attr_reader :description, :parsers, :namespaces, :target_namespace, :default_namespace, :log_msgs

      def initialize
        @base = self
        @description = WsdlMapper::SvcDesc::Wsdl11::Description.new

        @parsers = {
          MESSAGE => MessageParser.new(self),
          PORT_TYPE => PortTypeParser.new(self),
          SERVICE => ServiceParser.new(self),
          BINDING => BindingParser.new(self),
          TYPES => TypesParser.new(self)
          # TODO: import
        }

        @namespaces = Namespaces.new
        @target_namespace = nil
        @default_namespace = nil
        @log_msgs = []
      end

      # @param [Nokogiri::XML::Document] doc
      # @return [WsdlMapper::Dom::Schema]
      def parse doc
        # Phase 1: Parsing
        parse_doc doc

        # Phase 2: Linking
        link_types

        @description
      end

      # @param [Nokogiri::XML::Node] node
      # @param [String, Symbol] msg
      def log_msg node, msg = '', source = self
        log_msg = LogMsg.new(node, source, msg)
        log_msgs << log_msg
        # TODO: remove debugging output
        # puts node.inspect
        # puts msg
        # puts caller
        # puts "\n\n"
      end

      protected
      # @param [Nokogiri::XML::Document] doc
      def parse_doc doc
        parse_namespaces doc
        root = get_root doc
        @description.target_namespace = parse_target_namespace root
        @description.name = fetch_attribute_value 'name', root
        each_element root do |node|
          parse_node node
        end
      end

      def link_types
        link_messages
        link_port_types
        link_bindings
        link_services
      end

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
              part.element = @description.schema.get_element part.element_name
            elsif part.type_name
              part.type = @description.schema.get_type part.type_name
            end
          end
        end
      end

      # @param [Nokogiri::XML::Document] doc
      # @return [Nokogiri::XML::Node]
      def get_root doc
        doc.root
        # TODO: handle invalid roots, namespaces
      end
    end
  end
end
