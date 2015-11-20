require 'wsdl_mapper/parsing/logging'

module WsdlMapper
  module DomParsing
    class Linker
      include WsdlMapper::Parsing::Logging

      def initialize schema
        @schema = schema
        @log_msgs = []
      end

      def link
        link_base_types
        link_soap_array_types
        link_property_types
        link_attribute_types
        link_element_types

        @schema
      end

      private
      def link_element_types
        @schema.each_element do |element|
          if element.type_name
            element.type = @schema.get_type element.type_name

            unless element.type
              log_msg element.type, :missing_element_type
            end
          end
        end
      end

      def link_property_types
        @schema.each_type do |type|
          next unless type.is_a? WsdlMapper::Dom::ComplexType

          type.each_property do |prop|
            if prop.type_name
              prop.type = @schema.get_type prop.type_name

              unless prop.type
                log_msg prop, :missing_property_type
              end
            end
          end
        end
      end

      def link_attribute_types
        @schema.each_type do |type|
          next unless type.is_a? WsdlMapper::Dom::ComplexType

          type.each_attribute do |attr|
            if attr.is_a?(WsdlMapper::Dom::Attribute::Ref)
              type.add_attribute @schema.get_attribute attr.name
            elsif attr.type_name
              attr.type = @schema.get_type attr.type_name

              unless attr.type
                log_msg attr, :missing_attribute_type
              end
            end
          end
        end
      end

      def link_base_types
        @schema.each_type do |type|
          next unless type.base_type_name

          type.base = @schema.get_type type.base_type_name
          unless type.base
            log_msg type, :missing_base_type
          end
        end
      end

      def link_soap_array_types
        @schema.each_type do |type|
          next unless type.is_a? WsdlMapper::Dom::ComplexType
          next unless type.soap_array?

          type.soap_array_type = @schema.get_type type.soap_array_type_name
          unless type.soap_array_type
            log_msg type, :missing_soap_array_type
          end
        end
      end
    end
  end
end
