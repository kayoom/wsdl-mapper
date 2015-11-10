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
        link_services
        link_bindings
      end

      def link_bindings
        @description.each_binding do |b|
          b.type = @description.get_port_type b.type_name

          b.each_operation do |op|
            if op.input.header.message_name
              op.input.header.message = @description.get_message op.input.header.message_name
              op.input.header.part = op.input.header.message.get_part op.input.header.part_name
            end

            if op.output.header.message_name
              op.output.header.message = @description.get_message op.output.header.message_name
              op.output.header.part = op.output.header.message.get_part op.output.header.part_name
            end
          end
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
            op.input_message = @description.get_message op.input_message_name
            op.output_message = @description.get_message op.output_message_name
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
