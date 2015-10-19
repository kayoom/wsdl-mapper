require 'wsdl_mapper/schema/parser_base'
require 'wsdl_mapper/dom/simple_type'

module WsdlMapper
  module Schema
    class SimpleTypeParser < ParserBase

      def parse node
        name_str = node.attributes['name'].value
        name = parse_name name_str

        type = SimpleType.new name

        each_element node do |child|
          parse_simple_type_child child, type
        end

        @base.schema.add_type type
      end

      protected
      def parse_simple_type_child node, type
        case get_name node
        when RESTRICTION
          parse_simple_type_restriction node, type
        when ANNOTATION
          parse_annotation node, type
        else
          log_msg node, :unknown
        end
      end

      def parse_simple_type_restriction node, type
        parse_base node, type

        each_element node do |child|
          case get_name(child)
          when ENUMERATION
            parse_simple_type_enumeration child, type
          end
        end
      end

      def parse_simple_type_enumeration node, type
        value = node.attributes['value'].value

        enum = Enumeration.new value
        type.enumerations << enum
      end
    end
  end
end