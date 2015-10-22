require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module TypeMapping
    String = Base.new do
      register_xml_types %w[
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

      def to_ruby string
        string.to_s
      end

      def to_xml object
        object.to_s
      end
    end
  end
end
