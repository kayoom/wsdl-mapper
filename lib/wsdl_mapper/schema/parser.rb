require 'wsdl_mapper/schema/parser_base'

require 'wsdl_mapper/schema/complex_type_parser'
require 'wsdl_mapper/schema/simple_type_parser'
require 'wsdl_mapper/schema/annotation_parser'
require 'wsdl_mapper/schema/import_parser'

require 'wsdl_mapper/dom/schema'

module WsdlMapper
  module Schema
    class Parser < ParserBase
      include WsdlMapper::Schema::Xsd

      class ParserException < StandardError ; end
      class InvalidRootException < ParserException ; end
      class InvalidNsException < ParserException ; end

      attr_reader :schema, :parsers, :namespaces, :target_namespace, :default_namespace, :log_msgs

      def initialize
        @base = self
        @schema = WsdlMapper::Dom::Schema.new

        @parsers = {
          COMPLEX_TYPE  => ComplexTypeParser.new(self),
          ANNOTATION    => AnnotationParser.new(self),
          SIMPLE_TYPE   => SimpleTypeParser.new(self),
          IMPORT        => ImportParser.new(self)
        }

        @namespaces = {}
        @target_namespace = nil
        @default_namespace = nil
        @log_msgs = []
      end

      def parse doc
        parse_namespaces doc

        schema_node = get_schema_node doc

        parse_target_namespace schema_node

        each_element schema_node do |node|
          parse_node node
        end

        link_types

        @schema
      end

      def log_msg node, msg = '', source = self
        log_msg = LogMsg.new(node, source, msg)
        log_msgs << log_msg
        # TODO: remove debugging output
        puts node.inspect
        puts msg
        puts caller
        puts "\n\n"
      end

      protected
      def link_types
        link_base_types
        link_property_types
        link_attribute_types
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

      def parse_target_namespace node
        attr = node.attributes[TARGET_NS]
        if attr
          @target_namespace = attr.value
          @schema.target_namespace = @target_namespace
        end
      end

      def parse_namespaces doc
        doc.namespaces.each do |key, ns|
          if key == NS_DECL_PREFIX
            @default_namespace = ns
          else
            code = key.sub /^#{NS_DECL_PREFIX}\:/, ''
            @namespaces[code] = ns
          end
        end
      end

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
