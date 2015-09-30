require 'wsdl_mapper/schema/parser_base'

module WsdlMapper
  module Schema
    class ComplexTypeParser < ParserBase

      def parse node
        name_str = node.attributes['name'].value
        name = parse_name name_str

        type = ComplexType.new name

        node.children.each do |child|
          parse_complex_type_child child, type
        end

        type.documentation = parse_annotation node

        @base.schema.add_type type
      end

      def parse_complex_type_child node, type
        case get_name node
        when SEQUENCE
          parse_complex_type_sequence node, type
        when COMPLEX_CONTENT
          parse_complex_content node, type
        end
      end

      def parse_complex_content node, type
        child = first_element node

        case get_name child
        when EXTENSION
          parse_extension child, type
        end
      end

      def parse_extension node, type
        child = first_element node

        base_type_name = parse_name node.attributes['base'].value
        type.base = @base.schema.get_type base_type_name

        case get_name child
        when SEQUENCE
          parse_extension_sequence child, type
        end

      end

      def parse_extension_sequence node, type
        parse_complex_type_sequence node, type
      end

      def parse_complex_type_sequence node, type
        i = 0

        node.children.each do |elm|
          next unless name_matches? elm, ELEMENT

          name_str = elm.attributes['name'].value
          name = Name.new nil, name_str
          type_name_str = elm.attributes['type'].value
          type_name = parse_name type_name_str
          bounds = parse_bounds elm

          prop = Property.new name, type_name, sequence: i, bounds: bounds
          prop.documentation = parse_annotation elm
          type.add_property prop
          i += 1
        end
      end
    end
  end
end
