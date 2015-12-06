require 'wsdl_mapper/serializers/serializer_core'

module WsdlMapper
  module Serializers
    class SerializerFactory
      def initialize(type_directory, default_namespace: nil)
        @type_directory = type_directory
        @default_namespace = default_namespace
      end

      def to_xml(obj, element_name = nil)
        to_doc(obj, element_name).to_xml
      end

      def to_doc(obj, element_name = nil)
        element_name ||= @type_directory.get_element_name obj.class.name
        core = SerializerCore.new resolver: @type_directory, default_namespace: @default_namespace
        serializer = @type_directory.find obj
        serializer.build core, obj, element_name
        core.to_doc
      end
    end
  end
end
