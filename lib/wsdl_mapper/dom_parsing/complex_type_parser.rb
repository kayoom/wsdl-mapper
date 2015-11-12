require 'wsdl_mapper/dom_parsing/parser_base'
require 'wsdl_mapper/dom/complex_type'
require 'wsdl_mapper/dom/property'
require 'wsdl_mapper/dom/attribute'
require 'wsdl_mapper/dom/soap_encoding_type'
require 'wsdl_mapper/svc_desc_parsing/wsdl11'

module WsdlMapper
  module DomParsing
    class ComplexTypeParser < ParserBase

      def parse node
        name = parse_name_in_attribute 'name', node

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
        type_name = parse_name_in_attribute 'type', node

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
        ref = parse_name_in_attribute 'ref', node

        if ref != SoapEncodingType['arrayType'].name
          raise StandardError.new("Invalid ref attribute for SOAP array node: #{ref}")
        end

        type_name = parse_name node.attribute_with_ns(WsdlMapper::SvcDescParsing::Wsdl11::ARRAY_TYPE.name, WsdlMapper::SvcDescParsing::Wsdl11::ARRAY_TYPE.ns).value, node
        type.soap_array_type_name = Name.get type_name.ns, type_name.name[0..-3]
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
        name = parse_name_in_attribute 'name', node
        type_name = parse_name_in_attribute 'type', node

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
