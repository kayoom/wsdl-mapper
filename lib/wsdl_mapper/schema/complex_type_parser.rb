require 'wsdl_mapper/schema/parser_base'
require 'wsdl_mapper/dom/complex_type'
require 'wsdl_mapper/dom/property'
require 'wsdl_mapper/dom/attribute'

module WsdlMapper
  module Schema
    class ComplexTypeParser < ParserBase

      def parse node
        name_str = node.attributes['name'].value
        name = parse_name name_str

        type = ComplexType.new name

        each_element node do |child|
          parse_complex_type_child child, type
        end

        @base.schema.add_type type
      end

      def parse_complex_type_child node, type
        case get_name node
        when SEQUENCE
          parse_complex_type_sequence node, type
        when COMPLEX_CONTENT
          parse_complex_content node, type
        when ANNOTATION
          parse_annotation node, type
        when ATTRIBUTE
          parse_complex_type_attribute node, type
        else
          log_msg node, :unknown
        end
      end

      def parse_complex_type_attribute node, type
        name = node.attributes['name'].value
        # TODO:  -> Name.new ?
        type_name = parse_name node.attributes['type'].value

        attr = Attribute.new name, type_name
        type.add_attribute attr

        each_element node do |child|
          case get_name child
          when ANNOTATION
            parse_annotation child, attr
          else
            log_msg child, :unknown
          end
        end
      end

      def parse_complex_content node, type
        child = first_element node

        case get_name child
        when EXTENSION
          parse_extension child, type
        when ANNOTATION
        else
          log_msg child, :unknown
        end
      end

      def parse_extension node, type
        parse_base node, type

        each_element node do |child|
          case get_name child
          when SEQUENCE
            parse_extension_sequence child, type
          else
            log_msg child, :unknown
          end
        end
      end

      def parse_extension_sequence node, type
        parse_complex_type_sequence node, type
      end

      def parse_complex_type_sequence node, type
        i = 0

        each_element node do |elm|
          next unless name_matches? elm, ELEMENT

          parse_complex_type_property elm, type, i
          i += 1
        end
      end

      def parse_complex_type_property elm, type, i
        name_str = elm.attributes['name'].value
        name = Name.new nil, name_str

        type_name_str = elm.attributes['type'].value
        type_name = parse_name type_name_str

        bounds = parse_bounds elm

        prop = Property.new name, type_name, sequence: i, bounds: bounds
        type.add_property prop

        each_element elm do |child|
          parse_property_child child, prop
        end
      end

      def parse_property_child child, prop
        case get_name child
        when ANNOTATION
          parse_annotation child, prop
        else
          log_msg child, :unknown
        end
      end
    end
  end
end
