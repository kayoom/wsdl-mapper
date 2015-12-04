require 'wsdl_mapper/dom_parsing/xsd'
require 'wsdl_mapper/dom/documentation'
require 'wsdl_mapper/dom/bounds'
require 'wsdl_mapper/parsing/base'

module WsdlMapper
  module DomParsing
    class ParserBase < WsdlMapper::Parsing::Base
      include Xsd

      protected
      def parse_base(node, type)
        type.base_type_name = parse_name_in_attribute 'base', node
      end

      def parse_annotation(node, type)
        type.documentation = @base.parsers[ANNOTATION].parse node
      end

      def parse_bounds(node, container)
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
    end
  end
end

