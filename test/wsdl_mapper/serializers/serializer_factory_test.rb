require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/serializers/serializer_factory'
require 'wsdl_mapper/serializers/type_directory'

module SerializersTests
  class SerializerFactoryTest < ::Minitest::Test
    include WsdlMapper::Serializers
    include WsdlMapper::Dom

    class NoteTypeSerializer
      def build x, obj, name
        x.complex [nil, 'noteType'], [nil, 'note'], [] do |x|
          x.value_builtin [nil, 'to'], 'to@example.org', :string
          x.value_builtin [nil, 'from'], 'from@example.org', :string
        end
      end
    end

    class NoteType < Struct.new(:to, :from)
    end

    def test_simple
      type_directory = ::WsdlMapper::Serializers::TypeDirectory.new do
        register_type(NoteType.name, 'note_type_serializer', NoteTypeSerializer.name)
      end
      type_directory.register_serializer NoteTypeSerializer.name, NoteTypeSerializer.new
      type_directory.register_element NoteType.name, [nil, 'note']

      def type_directory.require path;end

      serializer_factory = WsdlMapper::Serializers::SerializerFactory.new type_directory

      xml = serializer_factory.to_xml NoteType.new('to@example.org', 'from@example.org')
      assert_equal <<XML, xml
<?xml version="1.0" encoding="UTF-8"?>
<note>
  <to>to@example.org</to>
  <from>from@example.org</from>
</note>
XML
    end
  end
end
