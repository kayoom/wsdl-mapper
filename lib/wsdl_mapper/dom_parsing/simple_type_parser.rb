require 'wsdl_mapper/dom_parsing/parser_base'
require 'wsdl_mapper/dom/simple_type'

module WsdlMapper
  module DomParsing
    class SimpleTypeParser < ParserBase

      def parse node
        name = parse_name_in_attribute 'name', node

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
        # TODO: test
        parse_base node, type

        each_element node do |child|
          case get_name(child)
          when ENUMERATION
            parse_simple_type_enumeration child, type
          when PATTERN
            parse_simple_type_pattern child, type
          when MIN_INCLUSIVE
            parse_simple_type_min child, type, true
          when MAX_INCLUSIVE
            parse_simple_type_max child, type, true
          when MIN_LENGTH
            parse_simple_type_min child, type, false
          when MAX_LENGTH
            parse_simple_type_max child, type, false
          when TOTAL_DIGITS
            parse_simple_type_total_digits child, type
          when FRACTION_DIGITS
            parse_simple_type_fraction_digits child, type
          else
            log_msg child, :unknown
          end
        end
      end

      def parse_simple_type_fraction_digits node, type
        type.fraction_digits = fetch_attribute_value 'value', node
      end

      def parse_simple_type_total_digits node, type
        type.total_digits = fetch_attribute_value 'value', node
      end

      def parse_simple_type_pattern node, type
        type.pattern = fetch_attribute_value 'value', node
      end

      def parse_simple_type_min node, type, inclusive
        type.min = fetch_attribute_value 'value', node
        type.min_inclusive = inclusive
      end

      def parse_simple_type_max node, type, inclusive
        type.max = fetch_attribute_value 'value', node
        type.max_inclusive = inclusive
      end

      def parse_simple_type_enumeration node, type
        value = node.attributes['value'].value

        enum_value = EnumerationValue.new value
        type.enumeration_values << enum_value

        each_element node do |child|
          case get_name(child)
          when ANNOTATION
            parse_annotation child, enum_value
          else
            log_msg node, :unknown
          end
        end
      end
    end
  end
end
