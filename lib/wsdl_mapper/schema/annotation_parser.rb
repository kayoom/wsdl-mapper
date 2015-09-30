require 'wsdl_mapper/schema/parser_base'

module WsdlMapper
  module Schema
    class AnnotationParser < ParserBase
      def parse node
        return Documentation.new(nil) unless node

        doc_node = find_node node, DOCUMENTATION
        text = doc_node && doc_node.text

        doc = Documentation.new text
        doc.app_info = parse_app_info node

        doc
      end

      def parse_app_info node
        app_info_node = find_node node, APPINFO

        app_info_node && app_info_node.children.to_s
      end
    end
  end
end
