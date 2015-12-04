require 'test_helper'

require 'wsdl_mapper/dom_parsing/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/documented_ctr_generator'

require 'wsdl_mapper/dom/property'

module DomGenerationTests
  module GeneratorTests
    class DocumentedCtrGeneratorTest < GenerationTest
      include WsdlMapper::Dom
      include WsdlMapper::DomGeneration

      def generate(name)
        schema = TestHelper.parse_schema name
        generator = SchemaGenerator.new context, ctr_generator_factory: DocumentedCtrGenerator
        generator.generate schema
      end

      def test_documentation_with_array
        generate 'basic_note_type_with_attachments.xsd'

        assert_file_is "note_type.rb", <<RUBY
class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body
  attr_accessor :attachments

  # This is the autogenerated default constructor.
  #
  # @param to [String]
  # @param from [String]
  # @param heading [String]
  # @param body [String]
  # @param attachments [Array<String>]
  #
  def initialize(to: nil, from: nil, heading: nil, body: nil, attachments: [])
    @to = to
    @from = from
    @heading = heading
    @body = body
    @attachments = attachments
  end
end
RUBY
      end

      def test_simple_class_generation
        generate 'basic_note_type_with_boolean_property_and_documentation.xsd'

        assert_file_is "note_type.rb", <<RUBY
class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body
  attr_accessor :sent

  # This is the autogenerated default constructor.
  #
  # @param to [String] the recipient of this note
  # @param from [String] the sender of this note
  # @param heading [String]
  # @param body [String]
  # @param sent [true, false]
  #
  def initialize(to: nil, from: nil, heading: nil, body: nil, sent: nil)
    @to = to
    @from = from
    @heading = heading
    @body = body
    @sent = sent
  end
end
RUBY
      end
    end
  end
end

