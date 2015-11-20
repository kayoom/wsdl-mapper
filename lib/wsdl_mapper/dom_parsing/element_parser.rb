require 'wsdl_mapper/dom_parsing/parser_base'
require 'wsdl_mapper/dom/element'

module WsdlMapper
  module DomParsing
    class ElementParser < ParserBase
      # @param [Nokogiri::XML::Node] node
      def parse node
        name = parse_name_in_attribute 'name', node

        element = Element.new name

        element.type_name = parse_name_in_attribute 'type', node

        each_element node do |child|
          parse_element_child child, element
        end

        @base.schema.add_element element
      end

      protected
      # @param [Nokogiri::XML::Node] node
      # @param [WsdlMapper::Dom::Element] element
      def parse_element_child node, element
        case get_name node
        when ANNOTATION
          parse_annotation node, element
        when COMPLEX_TYPE
          element.type = @base.parsers[COMPLEX_TYPE].parse node
          element.type.containing_element = element
        when SIMPLE_TYPE
          element.type = @base.parsers[SIMPLE_TYPE].parse node
          element.type.containing_element = element
        when UNIQUE
          # ignore
        else
          log_msg node, :unknown
        end
      end
    end
  end
end
