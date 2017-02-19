require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/serializers/type_directory'

module SerializersTests
  class TypeDirectoryTest < ::WsdlMapperTesting::Test
    include WsdlMapper::Serializers
    include WsdlMapper::Dom

    class NoteTypeSerializer
    end
    class NoteType
    end

    def test_simple
      type_directory = ::WsdlMapper::Serializers::TypeDirectory.new do
        register_type(NoteType.name, 'note_type_serializer', NoteTypeSerializer.name)
      end
      type_directory.register_serializer NoteTypeSerializer.name, NoteTypeSerializer.new
      type_directory.register_element NoteType.name, [nil, 'note']

      def type_directory.require(_path);
      end

      assert_kind_of NoteTypeSerializer, type_directory.resolve(NoteType.name)
      assert_kind_of NoteTypeSerializer, type_directory.find(NoteType.new)
      assert_equal Name.get(nil, 'note'), type_directory.get_element_name(NoteType.name)
    end
  end
end
