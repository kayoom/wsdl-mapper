require 'wsdl_mapper/serializers/serializer_core'

module WsdlMapper
  module Serializers
    class Serializer
      def initialize(type_directory, type_serializer)
        @type_directory = type_directory
        @type_serializer = type_serializer
      end

      def to_xml(obj, element_name = nil)
        element_name ||= @type_directory.get_element_name obj
        core = SerializerCore.new @type_directory
        @type_serializer.build core, obj, element_name
      end
    end
  end
end
