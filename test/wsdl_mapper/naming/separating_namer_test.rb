require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/naming/separating_namer'

module NamingTests
  class SeparatingNamerTest < ::Minitest::Test
    class TestType < Struct.new(:name)
    end

    class TestProperty < Struct.new(:name)
    end

    def test_simple_s8r_name_with_module_path
      name = WsdlMapper::Dom::Name.get nil, 'noteType'
      type = TestType.new name

      namer = WsdlMapper::Naming::SeparatingNamer.new module_path: %w[NotesApi]
      type_name = namer.get_s8r_name type

      assert_equal 'NoteTypeSerializer', type_name.class_name
      assert_equal 'note_type_serializer.rb', type_name.file_name
      assert_equal %w[NotesApi S8r], type_name.module_path
      assert_equal %w[notes_api s8r], type_name.file_path
    end

    def test_simple_d10r_name_with_module_path
      name = WsdlMapper::Dom::Name.get nil, 'noteType'
      type = TestType.new name

      namer = WsdlMapper::Naming::SeparatingNamer.new module_path: %w[NotesApi]
      type_name = namer.get_d10r_name type

      assert_equal 'NoteTypeDeserializer', type_name.class_name
      assert_equal 'note_type_deserializer.rb', type_name.file_name
      assert_equal %w[NotesApi D10r], type_name.module_path
      assert_equal %w[notes_api d10r], type_name.file_path
    end

    def test_simple_type_name_with_module_path
      name = WsdlMapper::Dom::Name.get nil, 'noteType'
      type = TestType.new name

      namer = WsdlMapper::Naming::SeparatingNamer.new module_path: %w[NotesApi]
      type_name = namer.get_type_name type

      assert_equal 'NoteType', type_name.class_name
      assert_equal 'note_type.rb', type_name.file_name
      assert_equal %w[NotesApi Types], type_name.module_path
      assert_equal %w[notes_api types], type_name.file_path
    end
  end
end
