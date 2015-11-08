require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/documented_class_generator'

module DomGenerationTests
  module GeneratorTests
    class DocumentedClassGeneratorTest < GenerationTestCase
      include WsdlMapper::DomGeneration

      def generate name
        schema = TestHelper.parse_schema name        
        generator = SchemaGenerator.new context, class_generator_factory: DocumentedClassGenerator
        generator.generate schema
      end

      def test_class_documentation
        generate 'empty_note_type_with_multiline_documentation.xsd'

        assert_file_is "note_type.rb", <<RUBY
# This is some documentation for noteType.
# With multiple lines.
#
# @xml_name noteType
class NoteType
end
RUBY
      end

      def test_class_documentation_with_namespace
        generate 'empty_note_with_documentaion_and_target_namespace.xsd'

        assert_file_is "note_type.rb", <<RUBY
# This is some documentation for noteType.
#
# @xml_name noteType
# @xml_namespace http://example.org/notes.xsd
class NoteType
end
RUBY
      end

      def test_property_documentation_with_array
        generate 'basic_note_type_with_attachments.xsd'

        assert_file_is "note_type.rb", <<RUBY
# @xml_name noteType
class NoteType
  # @!attribute to
  #   @return [String]
  #   @xml_name to
  attr_accessor :to

  # @!attribute from
  #   @return [String]
  #   @xml_name from
  attr_accessor :from

  # @!attribute heading
  #   @return [String]
  #   @xml_name heading
  attr_accessor :heading

  # @!attribute body
  #   @return [String]
  #   @xml_name body
  attr_accessor :body

  # @!attribute attachments
  #   @return [Array<String>]
  #   @xml_name attachments
  attr_accessor :attachments
end
RUBY
      end

      def test_property_documentation
        generate 'basic_note_type_with_property_and_attribute_documentation.xsd'

        assert_file_is "note_type.rb", <<RUBY
# @xml_name noteType
class NoteType
  # @!attribute to
  #   the recipient of this note
  #   @return [String]
  #   @xml_name to
  attr_accessor :to

  # @!attribute from
  #   the sender of this note
  #   @return [String]
  #   @xml_name from
  attr_accessor :from

  # @!attribute heading
  #   @return [String]
  #   @xml_name heading
  attr_accessor :heading

  # @!attribute body
  #   @return [String]
  #   @xml_name body
  attr_accessor :body

  # @!attribute uuid
  #   a unique identifier
  #   @return [String]
  #   @xml_name uuid
  attr_accessor :uuid
end
RUBY
      end

      def test_property_documentation_with_boolean
        generate 'basic_note_type_with_boolean_property.xsd'

        assert_file_is "note_type.rb", <<RUBY
# @xml_name noteType
class NoteType
  # @!attribute to
  #   @return [String]
  #   @xml_name to
  attr_accessor :to

  # @!attribute from
  #   @return [String]
  #   @xml_name from
  attr_accessor :from

  # @!attribute heading
  #   @return [String]
  #   @xml_name heading
  attr_accessor :heading

  # @!attribute body
  #   @return [String]
  #   @xml_name body
  attr_accessor :body

  # @!attribute sent
  #   @return [true, false]
  #   @xml_name sent
  attr_accessor :sent
end
RUBY
      end
    end
  end
end
