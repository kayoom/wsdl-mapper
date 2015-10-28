require 'test_helper'

require 'wsdl_mapper/type_mapping'

module TypeMappingTests
  class TypeMappingTest < ::Minitest::Test
    include WsdlMapper::TypeMapping

    def test_completeness
      xsd_type_names = %w[
        anyURI
        base64Binary
        boolean
        double
        float
        hexBinary
        QName
        byte
        decimal
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
        date
        dateTime
        duration
        gDay
        gMonth
        gMonthDay
        gYear
        gYearMonth
        time
        ENTITIES
        ENTITY
        ID
        IDREF
        IDREFS
        language
        Name
        NCName
        NMTOKEN
        NMTOKENS
        normalizedString
        QName
        string
        token
      ]

      # ignored: NOTATION

      xsd_types = xsd_type_names.map do |n|
        WsdlMapper::Dom::BuiltinType[n]
      end

      xsd_types.each do |type|
        mapping = MappingSet.default.find!(type)
        refute_nil mapping, "Missing type mapping for #{type.name}."
        assert_kind_of Class, mapping.ruby_type unless mapping.ruby_type.nil?
      end
    end
  end
end
