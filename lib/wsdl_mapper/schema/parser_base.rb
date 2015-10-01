require 'wsdl_mapper/schema/xsd'
require 'wsdl_mapper/dom/documentation'
require 'wsdl_mapper/dom/bounds'

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
          "#{@msg}: #{@node} - #{@source.class.name}"
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
      def parse_base node, type
        base_type_name = parse_name node.attributes['base'].value
        type.base = @base.schema.get_type base_type_name
      end

      def log_msg node, msg
        @base.log_msg node, msg, self
      end

      def parse_node node
        name = get_name(node)
        return if name == ELEMENT

        parser = @base.parsers[name]

        if parser
          parser.parse node
        else
          log_msg node, :unknown
        end
      end

      def parse_annotation node, type
        type.documentation = @base.parsers[ANNOTATION].parse node
      end

      def parse_bounds node, container
        bounds = DEFAULT_BOUNDS[container].dup

        if bounds.nil?
          raise ArgumentError.new("Unknown container #{container}")
        end

        if node.attributes.has_key? 'minOccurs'
          bounds.min = node.attributes['minOccurs'].value.to_i
        end

        if node.attributes.has_key? 'maxOccurs'
          max = node.attributes['maxOccurs'].value
          bounds.max = max == 'unbounded' ? nil : max.to_i
        end

        bounds
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

      def first_element! node
        first_element(node) ||
          raise(ArgumentError.new("#{node.name} has no child elements."))
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

      def each_element node
        node.children.each do |child|
          next unless is_element? child
          yield child
        end
      end

      def fetch_attribute_value name, node, default_value = nil
        attr = node.attributes[name]
        attr ? attr.value : default_value
      end

      def parse_name name_str
        name, ns_code = name_str.split(':').reverse
        ns = ns_code.nil? ? @base.target_namespace : @base.namespaces[ns_code.to_s]

        Name.new ns, name
      end
    end
  end
end

