require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/naming/default_namer'

module NamingTests
  class DefaultNamerTest < ::Minitest::Test
    class TestType < Struct.new(:name)
    end

    class TestProperty < Struct.new(:name)
    end

    def test_simple_type_name
      name = WsdlMapper::Dom::Name.new nil, 'noteType'
      type = TestType.new name

      namer = WsdlMapper::Naming::DefaultNamer.new
      type_name = namer.get_type_name type

      assert_equal 'NoteType', type_name.class_name
      assert_equal 'note_type.rb', type_name.file_name
      assert_equal [], type_name.module_path
      assert_equal [], type_name.file_path
      assert_nil type_name.parent
    end

    def test_simple_type_name_with_module_path
      name = WsdlMapper::Dom::Name.new nil, 'noteType'
      type = TestType.new name

      namer = WsdlMapper::Naming::DefaultNamer.new module_path: %w[NotesApi Types]
      type_name = namer.get_type_name type

      assert_equal 'NoteType', type_name.class_name
      assert_equal 'note_type.rb', type_name.file_name
      assert_equal %w[NotesApi Types], type_name.module_path
      assert_equal %w[notes_api types], type_name.file_path

      parent = type_name.parent
      refute_nil parent
      assert_equal 'Types', parent.module_name
      assert_equal 'types.rb', parent.file_name
      assert_equal %w[NotesApi], parent.module_path
      assert_equal %w[notes_api], parent.file_path

      parent2 = parent.parent
      refute_nil parent2
      assert_equal 'NotesApi', parent2.module_name
      assert_equal 'notes_api.rb', parent2.file_name
      assert_equal [], parent2.module_path
      assert_equal [], parent2.file_path
      assert_nil parent2.parent
    end

    def test_simple_property_name
      name = WsdlMapper::Dom::Name.new nil, 'subject'
      prop = TestProperty.new name

      namer = WsdlMapper::Naming::DefaultNamer.new
      prop_name = namer.get_property_name prop

      assert_equal 'subject', prop_name.attr_name
      assert_equal '@subject', prop_name.var_name
    end
  end
end