require 'wsdl_mapper/schema/parser_base'
require 'wsdl_mapper/dom/complex_type'
require 'wsdl_mapper/dom/property'
require 'wsdl_mapper/dom/attribute'
require 'wsdl_mapper/dom/soap_encoding_type'
require 'wsdl_mapper/schema/wsdl'

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
        when ALL
          parse_complex_type_all node, type
        when COMPLEX_CONTENT
          parse_complex_content node, type
        when SIMPLE_CONTENT
          parse_simple_content node, type
        when ANNOTATION
          parse_annotation node, type
        when ATTRIBUTE
          parse_attribute node, type
        else
          log_msg node, :unknown
        end
      end

      def parse_complex_type_all node, type
        each_element node do |child|
          parse_complex_type_property child, type, -1, ALL
        end
      end

      def parse_simple_content node, type
        type.simple_content = true
        each_element node do |child|
          case get_name child
          when EXTENSION
            parse_extension child, type
          else
            log_msg node, :unknown
          end
        end
      end

      def parse_attribute node, type
        name = node.attributes['name'].value
        # TODO:  -> Name.new ?
        type_name = parse_name node.attributes['type'].value

        attr = Attribute.new name, type_name,
          default: fetch_attribute_value('default', node),
          use: fetch_attribute_value('use', node, 'optional'),
          fixed: fetch_attribute_value('fixed', node),
          form: fetch_attribute_value('form', node)
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
        when RESTRICTION
          parse_complex_content_restriction child, type
        else
          log_msg child, :unknown
        end
      end

      def parse_complex_content_restriction node, type
        parse_base node, type

        case type.base_type_name
        when SoapEncodingType['Array'].name
          parse_soap_array node, type
        else
          log_msg node, :unknown
        end
      end

      def parse_soap_array node, type
        type.soap_array = true
        each_element node do |child|
          case get_name child
          when ATTRIBUTE
            parse_soap_array_attribute child, type
          else
            log_msg child, :unknown
          end
        end
      end

      def parse_soap_array_attribute node, type
        ref = node.attributes['ref'].value

        if parse_name(ref) != SoapEncodingType['arrayType'].name
          raise StandardError.new("Invalid ref attribute for SOAP array node: #{parse_name(ref)}")
        end

        type_name = parse_name node.attribute_with_ns(Wsdl::ARRAY_TYPE.name, Wsdl::ARRAY_TYPE.ns).value
        type.soap_array_type_name = Name.new type_name.ns, type_name.name[0..-3]
      end

      def parse_extension node, type
        parse_base node, type

        each_element node do |child|
          case get_name child
          when SEQUENCE
            parse_extension_sequence child, type
          when ATTRIBUTE
            parse_attribute child, type
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

          parse_complex_type_property elm, type, i, SEQUENCE
          i += 1
        end
      end

      def parse_complex_type_property node, type, i, container
        name_str = node.attributes['name'].value
        name = parse_name name_str #Name.new @base.schema.target_namespace, name_str

        type_name_str = node.attributes['type'].value
        type_name = parse_name type_name_str

        bounds = parse_bounds node, container

        prop = Property.new name, type_name, sequence: i, bounds: bounds,
          default: fetch_attribute_value('default', node),
          fixed: fetch_attribute_value('fixed', node),
          form: fetch_attribute_value('form', node)
        type.add_property prop

        each_element node do |child|
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
