require 'test_helper'

require 'wsdl_mapper/dom_parsing/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/d10r_generation/d10r_generator'

module D10rGenerationTests
  class D10rGeneratorTests < GenerationTest
    def generate name
      schema = get_schema name
      generator = WsdlMapper::D10rGeneration::D10rGenerator.new context
      generator.generate schema
    end

    def test_basic_empty_type
      generate 'empty_note_type.xsd'

      assert_file_is 'd10r_type_directory.rb', <<RUBY
require "wsdl_mapper/deserializers/type_directory"

D10rTypeDirectory = ::WsdlMapper::Deserializers::TypeDirectory.new
RUBY

      assert_file_is 'note_type_deserializer.rb', <<RUBY
require "d10r_type_directory"
require "note_type"

NoteTypeDeserializer = ::D10rTypeDirectory.register_type([nil, "noteType"], ::NoteType) do
end
RUBY

      assert_file_is 'd10r_element_directory.rb', <<RUBY
require "d10r_type_directory"
require "wsdl_mapper/deserializers/element_directory"

D10rElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(::D10rTypeDirectory) do
  register_element [nil, "note"], [nil, "noteType"], "note_type_deserializer", "::NoteTypeDeserializer"
end
RUBY

      assert_file_is 'deserializer.rb', <<RUBY
require "wsdl_mapper/deserializers/lazy_loading_deserializer"
require "d10r_element_directory"

Deserializer = ::WsdlMapper::Deserializers::LazyLoadingDeserializer.new(::D10rElementDirectory)
RUBY
    end

    def test_simple_content
      generate 'simple_money_type_with_currency_attribute.xsd'

      assert_file_is 'money_type_deserializer.rb', <<RUBY
require "d10r_type_directory"
require "money_type"

MoneyTypeDeserializer = ::D10rTypeDirectory.register_type([nil, "moneyType"], ::MoneyType, simple: ["http://www.w3.org/2001/XMLSchema", "float"]) do
  register_attr(:currency, [nil, "currency"], ["http://www.w3.org/2001/XMLSchema", "token"])
end
RUBY
    end

    def test_basic_type
      generate 'basic_note_type.xsd'

      assert_file_is 'note_type_deserializer.rb', <<RUBY
require "d10r_type_directory"
require "note_type"

NoteTypeDeserializer = ::D10rTypeDirectory.register_type([nil, "noteType"], ::NoteType) do
  register_prop(:to, [nil, "to"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:from, [nil, "from"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:heading, [nil, "heading"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:body, [nil, "body"], ["http://www.w3.org/2001/XMLSchema", "string"])
end
RUBY
    end

    def test_basic_type_with_nesting
      generate 'basic_note_type_with_complex_attachments.xsd'

      assert_file_is 'note_type_deserializer.rb', <<RUBY
require "d10r_type_directory"
require "note_type"

require "attachment_type_deserializer"

NoteTypeDeserializer = ::D10rTypeDirectory.register_type([nil, "noteType"], ::NoteType) do
  register_attr(:uuid, [nil, "uuid"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:to, [nil, "to"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:from, [nil, "from"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:heading, [nil, "heading"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:body, [nil, "body"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:attachments, [nil, "attachments"], [nil, "attachmentType"], array: true)
end
RUBY
    end

    def test_basic_type_with_array
      generate 'basic_note_type_with_attachments.xsd'

      assert_file_is 'note_type_deserializer.rb', <<RUBY
require "d10r_type_directory"
require "note_type"

NoteTypeDeserializer = ::D10rTypeDirectory.register_type([nil, "noteType"], ::NoteType) do
  register_prop(:to, [nil, "to"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:from, [nil, "from"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:heading, [nil, "heading"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:body, [nil, "body"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:attachments, [nil, "attachments"], ["http://www.w3.org/2001/XMLSchema", "string"], array: true)
end
RUBY
    end

    def test_basic_type_with_array_simple_type
      generate 'basic_note_type_with_attachments_simple_type.xsd'

      assert_file_is 'note_type_deserializer.rb', <<RUBY
require "d10r_type_directory"
require "note_type"

NoteTypeDeserializer = ::D10rTypeDirectory.register_type([nil, "noteType"], ::NoteType) do
  register_prop(:to, [nil, "to"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:from, [nil, "from"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:heading, [nil, "heading"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:body, [nil, "body"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:attachments, [nil, "attachments"], ["http://www.w3.org/2001/XMLSchema", "string"], array: true)
end
RUBY
    end

    def test_basic_type_with_array_complex_type
      generate 'basic_note_type_with_complex_attachments.xsd'

      assert_file_is 'note_type_deserializer.rb', <<RUBY
require "d10r_type_directory"
require "note_type"

require "attachment_type_deserializer"

NoteTypeDeserializer = ::D10rTypeDirectory.register_type([nil, "noteType"], ::NoteType) do
  register_attr(:uuid, [nil, "uuid"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:to, [nil, "to"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:from, [nil, "from"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:heading, [nil, "heading"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:body, [nil, "body"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:attachments, [nil, "attachments"], [nil, "attachmentType"], array: true)
end
RUBY

      assert_file_is 'attachment_type_deserializer.rb', <<RUBY
require "d10r_type_directory"
require "attachment_type"

AttachmentTypeDeserializer = ::D10rTypeDirectory.register_type([nil, "attachmentType"], ::AttachmentType) do
  register_prop(:name, [nil, "name"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:body, [nil, "body"], ["http://www.w3.org/2001/XMLSchema", "string"])
end
RUBY
    end

    def test_extended_type
      generate 'basic_note_type_and_fancy_note_type_extension.xsd'

      assert_file_is 'note_type_deserializer.rb', <<RUBY
require "d10r_type_directory"
require "note_type"

NoteTypeDeserializer = ::D10rTypeDirectory.register_type([nil, "noteType"], ::NoteType) do
  register_prop(:to, [nil, "to"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:from, [nil, "from"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:heading, [nil, "heading"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:body, [nil, "body"], ["http://www.w3.org/2001/XMLSchema", "string"])
end
RUBY

      assert_file_is 'fancy_note_type_deserializer.rb', <<RUBY
require "d10r_type_directory"
require "fancy_note_type"

FancyNoteTypeDeserializer = ::D10rTypeDirectory.register_type([nil, "fancyNoteType"], ::FancyNoteType) do
  register_prop(:to, [nil, "to"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:from, [nil, "from"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:heading, [nil, "heading"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:body, [nil, "body"], ["http://www.w3.org/2001/XMLSchema", "string"])
  register_prop(:attachments, [nil, "attachments"], ["http://www.w3.org/2001/XMLSchema", "string"], array: true)
end
RUBY
    end

    def test_soap_array
      generate 'basic_note_type_with_soap_array.xsd'

      assert_file_is 'attachments_array_deserializer.rb', <<RUBY
require "d10r_type_directory"
require "attachments_array"

AttachmentsArrayDeserializer = ::D10rTypeDirectory.register_soap_array([nil, "attachmentsArray"], ::AttachmentsArray, [nil, "attachment"])
RUBY
    end
  end
end
