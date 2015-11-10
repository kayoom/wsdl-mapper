require 'wsdl_mapper/dom_parsing/parser_base'

require 'wsdl_mapper/dom_parsing/xsd'
require 'wsdl_mapper/dom_parsing/complex_type_parser'
require 'wsdl_mapper/dom_parsing/simple_type_parser'
require 'wsdl_mapper/dom_parsing/annotation_parser'
require 'wsdl_mapper/dom_parsing/import_parser'
require 'wsdl_mapper/dom_parsing/element_parser'

require 'wsdl_mapper/dom/schema'
require 'wsdl_mapper/dom/namespaces'

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
        @log_msgs = []
      end

      # @param [Nokogiri::XML::Document] doc
      # @return [WsdlMapper::Dom::Schema]
      def parse doc
        # Phase 1: Parsing
        parse_doc doc

        # Phase 2: Linking
        link_types

        @schema
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

      # @return [WsdlMapper::DomParsing::Parser]
      def dup
        self.class.new import_resolver: @import_resolver
      end

      protected
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

      def link_types
        link_base_types
        link_soap_array_types
        link_property_types
        link_attribute_types
        link_element_types
      end

      def link_element_types
        @schema.each_element do |element|
          element.type = @schema.get_type element.type_name

          unless element.type
            log_msg prop, :missing_element_type
          end
        end
      end

      def link_property_types
        @schema.each_type do |type|
          next unless type.is_a? WsdlMapper::Dom::ComplexType
          type.each_property do |prop|
            prop.type = @schema.get_type prop.type_name

            unless prop.type
              log_msg prop, :missing_property_type
            end
          end
        end
      end

      def link_attribute_types
        @schema.each_type do |type|
          next unless type.is_a? WsdlMapper::Dom::ComplexType
          type.each_attribute do |attr|
            attr.type = @schema.get_type attr.type_name

            unless attr.type
              log_msg attr, :missing_attribute_type
            end
          end
        end
      end

      def link_base_types
        @schema.each_type do |type|
          next unless type.base_type_name

          type.base = @schema.get_type type.base_type_name
          unless type.base
            log_msg type, :missing_base_type
          end
        end
      end

      def link_soap_array_types
        @schema.each_type do |type|
          next unless type.is_a? WsdlMapper::Dom::ComplexType
          next unless type.soap_array?

          type.soap_array_type = @schema.get_type type.soap_array_type_name
          unless type.soap_array_type
            log_msg type, :missing_soap_array_type
          end
        end
      end

      # @param [Nokogiri::XML::Document] doc
      def get_schema_node doc
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
