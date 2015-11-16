require 'wsdl_mapper/naming/type_name'
require 'wsdl_mapper/naming/property_name'
require 'wsdl_mapper/naming/enumeration_value_name'
require 'wsdl_mapper/naming/inflector'

module WsdlMapper
  module Naming
    # @abstract
    class AbstractNamer
      def get_type_name type
        raise NotImplementedError
      end

      def get_property_name property
        raise NotImplementedError
      end

      def get_enumeration_value_name type, enum_value
        raise NotImplementedError
      end

      def get_s8r_name type
        raise NotImplementedError
      end

      def get_d10r_name type
        raise NotImplementedError
      end

      def get_attribute_name attribute
        raise NotImplementedError
      end

      def get_content_name type
        raise NotImplementedError
      end

      def get_inline_type element
        raise NotImplementedError
      end
    end
  end
end

