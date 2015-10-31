require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/generation/schema_generator'
require 'wsdl_mapper/generation/documented_class_generator'

module GenerationTests
  module GeneratorTests
    class DocumentedClassGeneratorTest < Minitest::Test
      include WsdlMapper::Generation

      def setup
        @tmp_path = TestHelper.get_tmp_path
      end

      def teardown
        @tmp_path.unlink
      end

      def test_class_documentation
        schema = TestHelper.parse_schema 'empty_note_type_with_multiline_documentation.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, class_generator_factory: DocumentedClassGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
# This is some documentation for noteType.
# With multiple lines.
#
# @xml_name noteType
class NoteType
end
RUBY
      end

      def test_class_documentation_with_namespace
        schema = TestHelper.parse_schema 'empty_note_with_documentaion_and_target_namespace.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, class_generator_factory: DocumentedClassGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
# This is some documentation for noteType.
#
# @xml_name noteType
# @xml_namespace http://example.org/notes.xsd
class NoteType
end
RUBY
      end

      def test_property_documentation_with_array
        schema = TestHelper.parse_schema 'basic_note_type_with_attachments.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, class_generator_factory: DocumentedClassGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
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
        schema = TestHelper.parse_schema 'basic_note_type_with_property_and_attribute_documentation.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, class_generator_factory: DocumentedClassGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
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
        schema = TestHelper.parse_schema 'basic_note_type_with_boolean_property.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, class_generator_factory: DocumentedClassGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
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
