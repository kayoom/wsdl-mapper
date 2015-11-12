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
require 'wsdl_mapper/svc_desc_parsing/linker'

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
        @linker = Linker.new @description
      end

      # @param [Nokogiri::XML::Document] doc
      # @return [WsdlMapper::Dom::Schema]
      def parse doc
        # Phase 1: Parsing
        parse_doc doc

        # Phase 2: Linking
        @linker.link

        @description
      end

      # @param [Nokogiri::XML::Node] node
      # @param [String, Symbol] msg
      def log_msg node, msg = '', source = self
        log_msg = LogMsg.new(node, source, msg)
        log_msgs << log_msg
        # TODO: remove debugging output
        puts node.inspect
        puts msg
        puts caller
        puts "\n\n"
      end

      def parse_documentation node, obj
        obj.documentation = node.text
      end

      protected
      # @param [Nokogiri::XML::Document] doc
      def parse_doc doc
        parse_namespaces doc
        root = get_root doc
        @description.target_namespace = parse_target_namespace root
        @description.name = fetch_attribute_value 'name', root
        each_element root do |node|
          if get_name(node) == DOCUMENTATION
            parse_documentation node, @description
          else
            parse_node node
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
