require 'test_helper'

require 'wsdl_mapper/dom_parsing/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/default_ctr_generator'

module DomGenerationTests
  module GeneratorTests
    class DefaultWrappingTypeGeneratorTest < GenerationTest
      include WsdlMapper::DomGeneration

      def generate(name)
        schema = TestHelper.parse_schema name
        generator = SchemaGenerator.new context
        generator.generate schema
      end

      # TODO: complex type with simple content!

      def test_generation
        generate 'simple_email_address_type.xsd'

        assert_file_is 'email_address_type.rb', <<RUBY
class EmailAddressType
  attr_accessor :content
end
RUBY
      end

      def test_inline_complex_type
        generate 'basic_note_type_with_inline_simple_type.xsd'

        assert_file_is 'attachment_inline_type.rb', <<RUBY
class AttachmentInlineType
  attr_accessor :content
end
RUBY

        assert_file_is 'note_type.rb', <<RUBY
require "attachment_inline_type"

class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body
  attr_accessor :attachment
end
RUBY
      end

      def test_element_inline_complex_type
        generate 'element_inline_simple_type.xsd'

        assert_file_is 'email_inline_type.rb', <<RUBY
class EmailInlineType
  attr_accessor :content
end
RUBY
      end
    end
  end
end

