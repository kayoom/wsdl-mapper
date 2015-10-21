require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module TypeMapping
    Integer = Base.new do
      register_ruby_types [
        Integer
      ]

      register_xml_types %w[
        byte
        int
        integer
        long
        negativeInteger
        nonNegativeInteger
        nonPositiveInteger
        positiveInteger
        short
        unsignedLong
        unsignedInt
        unsignedShort
        unsignedByte
      ]

      def to_ruby string
        string.to_s.to_i
      end

      def to_xml int
        int.to_i.to_s
      end
    end
  end
end
