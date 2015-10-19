require 'test_helper'

require 'wsdl_mapper/naming/type_name'

module NamingTests
  class TypeNameTest < ::Minitest::Test
    include WsdlMapper::Naming

    def test_simple_name
      type_name = TypeName.new 'NoteType', [], 'note_type.rb', []

      assert_equal '::NoteType', type_name.name
      assert_equal 'note_type', type_name.require_path
      assert_equal nil, type_name.parent
      assert_empty type_name.parents
    end

    def test_name_nested_in_modules
      type_name = TypeName.new 'NoteType', ['NotesApi', 'Types'], 'note_type.rb', ['notes_api', 'types']

      assert_equal '::NotesApi::Types::NoteType', type_name.name
      assert_equal 'notes_api/types/note_type', type_name.require_path
      assert_equal nil, type_name.parent
      assert_empty type_name.parents
    end

    def test_name_with_parents
      type_name = TypeName.new 'NoteType', ['NotesApi', 'Types'], 'note_type.rb', ['notes_api', 'types']
      parent1 = TypeName.new 'Types', ['NotesApi'], 'types.rb', ['notes_api']
      parent2 = TypeName.new 'NotesApi', [], 'notes_api.rb', []
      type_name.parent = parent1
      parent1.parent = parent2

      assert_equal [parent1, parent2], type_name.parents
    end

    def test_equality_by_name
      type_name1 = TypeName.new 'NoteType', ['NotesApi', 'Types'], 'note_type.rb', ['notes_api', 'types']
      type_name2 = TypeName.new 'NoteType', ['NotesApi', 'Types'], 'note_type.rb', ['notes_api', 'types']

      assert type_name1 == type_name2
      assert type_name1.eql?(type_name2)

      hash = {
        type_name1 => 'foo'
      }
      assert_equal 'foo', hash[type_name2]
    end
  end
end
