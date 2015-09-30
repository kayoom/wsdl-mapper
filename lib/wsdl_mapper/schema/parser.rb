require 'wsdl_mapper/schema/parser_base'

require 'wsdl_mapper/schema/complex_type_parser'
require 'wsdl_mapper/schema/annotation_parser'

module WsdlMapper
  module Schema
    class Parser < ParserBase
      include WsdlMapper::Schema::Xsd

      class ParserException < StandardError ; end
      class InvalidRootException < ParserException ; end
      class InvalidNsException < ParserException ; end

      attr_reader :schema, :parsers, :namespaces, :target_namespace, :default_namespace

      def initialize
        @base = self
        @schema = WsdlMapper::Dom::Schema.new

        @parsers = {
          COMPLEX_TYPE  => ComplexTypeParser.new(self),
          ANNOTATION    => AnnotationParser.new(self)
        }

        @namespaces = {}
        @target_namespace = nil
        @default_namespace = nil
      end

      def parse doc
        parse_namespaces doc

        schema_node = get_schema_node doc

        parse_target_namespace schema_node

        schema_node.children.each do |node|
          parse_node node
        end

        @schema
      end

      protected
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
        schema_node = doc.children.first

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
