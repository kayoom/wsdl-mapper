require 'wsdl_mapper/dom_parsing/parser_base'

require 'wsdl_mapper/dom_parsing/xsd'
require 'wsdl_mapper/dom_parsing/complex_type_parser'
require 'wsdl_mapper/dom_parsing/simple_type_parser'
require 'wsdl_mapper/dom_parsing/annotation_parser'
require 'wsdl_mapper/dom_parsing/import_parser'
require 'wsdl_mapper/dom_parsing/element_parser'

require 'wsdl_mapper/dom/schema'
require 'wsdl_mapper/dom/namespaces'
require 'wsdl_mapper/dom_parsing/linker'

module WsdlMapper
  module DomParsing
    class Parser < ParserBase
      include WsdlMapper::DomParsing::Xsd

      class ParserException < StandardError ; end
      class InvalidRootException < ParserException ; end
      class InvalidNsException < ParserException ; end

      attr_reader :schema, :parsers, :namespaces, :target_namespace, :default_namespace, :log_msgs, :import_resolver

      # @param [WsdlMapper::DomParsing::AbstractResolver] import_resolver
      def initialize import_resolver: nil
        @base = self
        @schema = WsdlMapper::Dom::Schema.new

        @parsers = {
          COMPLEX_TYPE  => ComplexTypeParser.new(self),
          ANNOTATION    => AnnotationParser.new(self),
          SIMPLE_TYPE   => SimpleTypeParser.new(self),
          IMPORT        => ImportParser.new(self),
          ELEMENT       => ElementParser.new(self)
        }

        @import_resolver = import_resolver
        @namespaces = Namespaces.new
        @target_namespace = nil
        @default_namespace = nil
        @linker = Linker.new schema
      end

      # @param [Nokogiri::XML::Document] doc
      # @return [WsdlMapper::Dom::Schema]
      def parse doc, parse_only: false
        # Phase 1: Parsing
        parse_doc doc

        # Phase 2: Linking
        unless parse_only
          @linker.link
        end

        collect_logs

        @schema
      end

      # @return [WsdlMapper::DomParsing::Parser]
      def dup
        self.class.new import_resolver: @import_resolver
      end

      protected
      def collect_logs
        @log_msgs ||= []
        @parsers.values.each do |parser|
          byebug if parser.log_msgs.nil?
          @log_msgs += parser.log_msgs
        end
        @log_msgs += @linker.log_msgs
      end

      # @param [Nokogiri::XML::Document] doc
      def parse_doc doc
        parse_namespaces doc
        schema_node = get_schema_node doc
        parse_attributes schema_node
        each_element schema_node do |node|
          parse_node node
        end
      end

      # @param [Nokogiri::XML::Node] schema_node
      def parse_attributes schema_node
        @schema.target_namespace = parse_target_namespace schema_node
        parse_element_form_default schema_node
        parse_attribute_form_default schema_node
      end

      # @param [Nokogiri::XML::Node] node
      def parse_attribute_form_default node
        attr = node.attributes[ATTRIBUTE_FORM_DEFAULT]
        if attr && attr.value == "qualified"
          @schema.qualified_attributes = true
        end
      end

      # @param [Nokogiri::XML::Node] node
      def parse_element_form_default node
        attr = node.attributes[ELEMENT_FORM_DEFAULT]
        if attr && attr.value == "qualified"
          @schema.qualified_elements = true
        end
      end

      # @param [Nokogiri::XML::Document] doc
      def get_schema_node doc
        return doc if is_element?(doc) && get_name(doc) == SCHEMA
        schema_node = first_element doc

        if schema_node.namespace.nil? || schema_node.namespace.href != NS
          raise InvalidNsException
        end

        unless name_matches? schema_node, SCHEMA
          raise InvalidRootException
        end

        schema_node
      end
    end
  end
end
