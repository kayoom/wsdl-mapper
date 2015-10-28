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
        schema = TestHelper.parse_schema 'example_17.xsd'
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

#       def test_class_documentation_with_superclass
#         schema = TestHelper.parse_schema 'example_20.xsd'
#         context = Context.new @tmp_path.to_s
#         generator = SchemaGenerator.new context, class_generator_factory: DocumentedClassGenerator
#
#         result = generator.generate schema
#
#         expected_file = @tmp_path.join("note_type.rb")
#         assert File.exists? expected_file
#
#         generated_class = File.read expected_file
#         assert_equal <<RUBY, generated_class
# # This is some documentation for noteType.
# # With multiple lines.
# #
# # @xml_name noteType
# class NoteType
# end
# RUBY
#       end

      def test_class_documentation_with_namespace
        schema = TestHelper.parse_schema 'example_18.xsd'
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

      def test_property_documentation
        schema = TestHelper.parse_schema 'example_19.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, class_generator_factory: DocumentedClassGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
class NoteType
  # @!attribute to
  #   @return [String] the recipient of this note
  #   @xml_name to
  attr_accessor :to

  # @!attribute from
  #   @return [String] the sender of this note
  #   @xml_name from
  attr_accessor :from
end
RUBY
      end
    end
  end
end

