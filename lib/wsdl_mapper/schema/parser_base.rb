require 'wsdl_mapper/schema/xsd'
require 'wsdl_mapper/dom/documentation'

module WsdlMapper
  module Schema
    class ParserBase
      class LogMsg
        def initialize node, source, msg = ''
          @node = node
          @source = source
          @node_name = node && node.name
          @msg = msg
        end

        def to_s
          "#{@msg}: #{@node_name} - #{@source.class.name}"
        end
      end

      def initialize base
        @base = base
      end

      def self.get_name node
        ns = node.namespace ? node.namespace.href : nil
        name = node.name

        Name.new ns, name
      end

      include Xsd

      protected
      def parse_node node
        parser = @base.parsers[get_name(node)]

        if parser
          parser.parse node
        end
      end

      def parse_annotation node
        anno_node = find_node node, ANNOTATION
        @base.parsers[ANNOTATION].parse anno_node
      end

      def parse_bounds node
        min = 1
        max = 1

        if node.attributes.has_key? 'minOccurs'
          min = node.attributes['minOccurs'].value.to_i
        end

        if node.attributes.has_key? 'maxOccurs'
          max = node.attributes['maxOccurs'].value
          max = max == 'unbounded' ? nil : max.to_i
        end

        Bounds.new min: min, max: max
      end

      def get_name node
        self.class.get_name node
      end

      def is_element? node
        node.is_a? Nokogiri::XML::Element
      end

      def first_element node
        node.children.find { |n| is_element? n }
      end

      def select_nodes node, name
        node.children.select { |n| is_element?(n) && name_matches?(n, name) }
      end

      def find_node node, name
        node.children.find { |n| is_element?(n) && name_matches?(n, name) }
      end

      def name_matches? node, name
        return node.name == name.name && name.ns.nil? if node.namespace.nil?

        node.name == name.name && node.namespace.href == name.ns
      end

      def parse_name name_str
        name, ns_code = name_str.split(':').reverse
        ns = ns_code.nil? ? @base.target_namespace : @base.namespaces[ns_code.to_s]

        Name.new ns, name
      end
    end
  end
end

