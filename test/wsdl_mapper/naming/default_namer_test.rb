require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/naming/default_namer'

module NamingTests
  class DefaultNamerTest < ::Minitest::Test
    class TestType < Struct.new(:name)
    end

    class TestProperty < Struct.new(:name)
    end

    def test_numeric_enum_value_name
      enum_value1 = WsdlMapper::Dom::EnumerationValue.new '1'
      enum_value2 = WsdlMapper::Dom::EnumerationValue.new '1foo'

      namer = WsdlMapper::Naming::DefaultNamer.new
      enum_value_name1 = namer.get_enumeration_value_name nil, enum_value1
      enum_value_name2 = namer.get_enumeration_value_name nil, enum_value2

      assert_equal 'VALUE_1', enum_value_name1.constant_name
      assert_equal 'VALUE_1FOO', enum_value_name2.constant_name
      assert_equal 'value_1', enum_value_name1.key_name
      assert_equal 'value_1foo', enum_value_name2.key_name
    end

    def test_simple_enum_value_name
      enum_value1 = WsdlMapper::Dom::EnumerationValue.new 'ship_option'
      enum_value2 = WsdlMapper::Dom::EnumerationValue.new 'shipOption'

      namer = WsdlMapper::Naming::DefaultNamer.new
      enum_value_name1 = namer.get_enumeration_value_name nil, enum_value1
      enum_value_name2 = namer.get_enumeration_value_name nil, enum_value2

      assert_equal 'SHIP_OPTION', enum_value_name1.constant_name
      assert_equal 'SHIP_OPTION', enum_value_name2.constant_name
      assert_equal 'ship_option', enum_value_name1.key_name
      assert_equal 'ship_option', enum_value_name2.key_name
    end

    def test_simple_type_name
      name = WsdlMapper::Dom::Name.get nil, 'noteType'
      type = TestType.new name

      namer = WsdlMapper::Naming::DefaultNamer.new
      type_name = namer.get_type_name type

      assert_equal 'NoteType', type_name.class_name
      assert_equal 'note_type.rb', type_name.file_name
      assert_equal [], type_name.module_path
      assert_equal [], type_name.file_path
      assert_nil type_name.parent
    end

    def test_simple_s8r_name_with_module_path
      name = WsdlMapper::Dom::Name.get nil, 'noteType'
      type = TestType.new name

      namer = WsdlMapper::Naming::DefaultNamer.new module_path: %w[NotesApi Types]
      type_name = namer.get_s8r_name type

      assert_equal 'NoteTypeSerializer', type_name.class_name
      assert_equal 'note_type_serializer.rb', type_name.file_name
      assert_equal %w[NotesApi Types], type_name.module_path
      assert_equal %w[notes_api types], type_name.file_path
    end

    def test_simple_d10r_name_with_module_path
      name = WsdlMapper::Dom::Name.get nil, 'noteType'
      type = TestType.new name

      namer = WsdlMapper::Naming::DefaultNamer.new module_path: %w[NotesApi Types]
      type_name = namer.get_d10r_name type

      assert_equal 'NoteTypeDeserializer', type_name.class_name
      assert_equal 'note_type_deserializer.rb', type_name.file_name
      assert_equal %w[NotesApi Types], type_name.module_path
      assert_equal %w[notes_api types], type_name.file_path
    end

    def test_simple_type_name_with_module_path
      name = WsdlMapper::Dom::Name.get nil, 'noteType'
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
      name = WsdlMapper::Dom::Name.get nil, 'subject'
      prop = TestProperty.new name

      namer = WsdlMapper::Naming::DefaultNamer.new
      prop_name = namer.get_property_name prop

      assert_equal 'subject', prop_name.attr_name
      assert_equal '@subject', prop_name.var_name
    end
  end
end
