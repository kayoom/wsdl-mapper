require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/d10r_generation/d10r_generator'

module D10rGenerationTests
  class D10rGeneratorTests < GenerationTestCase
    def generate name
      schema = get_schema name
      generator = WsdlMapper::D10rGeneration::D10rGenerator.new context
      generator.generate schema
    end

    def test_basic_empty_type
      generate 'empty_note_type.xsd'

      assert_file_is "deserializer_factory.rb", <<RUBY
require "wsdl_mapper/deserializers/deserializer_factory"

DeserializerFactory = ::WsdlMapper::Deserializers::DeserializerFactory.new

RUBY

      assert_file_is "note_type_deserializer.rb", <<RUBY
require "deserializer_factory"
require "note_type"

NoteTypeDeserializer = ::DeserializerFactory.register(nil, "noteType", ::NoteType) do
end
RUBY
    end

    def test_basic_type
      generate 'basic_note_type.xsd'

      assert_file_is "note_type_deserializer.rb", <<RUBY
require "deserializer_factory"
require "note_type"

NoteTypeDeserializer = ::DeserializerFactory.register(nil, "noteType", ::NoteType) do
  register_prop :to, ::WsdlMapper::Dom::Name.get(nil, "to"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :from, ::WsdlMapper::Dom::Name.get(nil, "from"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :heading, ::WsdlMapper::Dom::Name.get(nil, "heading"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :body, ::WsdlMapper::Dom::Name.get(nil, "body"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
end
RUBY
    end

    def test_basic_type_with_array
      generate 'basic_note_type_with_attachments.xsd'

      assert_file_is "note_type_deserializer.rb", <<RUBY
require "deserializer_factory"
require "note_type"

NoteTypeDeserializer = ::DeserializerFactory.register(nil, "noteType", ::NoteType) do
  register_prop :to, ::WsdlMapper::Dom::Name.get(nil, "to"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :from, ::WsdlMapper::Dom::Name.get(nil, "from"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :heading, ::WsdlMapper::Dom::Name.get(nil, "heading"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :body, ::WsdlMapper::Dom::Name.get(nil, "body"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :attachments, ::WsdlMapper::Dom::Name.get(nil, "attachments"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string"), array: true
end
RUBY
    end

    def test_basic_type_with_array_simple_type
      generate 'basic_note_type_with_attachments_simple_type.xsd'

      assert_file_is "note_type_deserializer.rb", <<RUBY
require "deserializer_factory"
require "note_type"

NoteTypeDeserializer = ::DeserializerFactory.register(nil, "noteType", ::NoteType) do
  register_prop :to, ::WsdlMapper::Dom::Name.get(nil, "to"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :from, ::WsdlMapper::Dom::Name.get(nil, "from"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :heading, ::WsdlMapper::Dom::Name.get(nil, "heading"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :body, ::WsdlMapper::Dom::Name.get(nil, "body"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :attachments, ::WsdlMapper::Dom::Name.get(nil, "attachments"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string"), array: true
end
RUBY
    end

    def test_basic_type_with_array_complex_type
      generate 'basic_note_type_with_complex_attachments.xsd'

      assert_file_is "note_type_deserializer.rb", <<RUBY
require "deserializer_factory"
require "note_type"

NoteTypeDeserializer = ::DeserializerFactory.register(nil, "noteType", ::NoteType) do
  register_attr :uuid, ::WsdlMapper::Dom::Name.get(nil, "uuid"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :to, ::WsdlMapper::Dom::Name.get(nil, "to"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :from, ::WsdlMapper::Dom::Name.get(nil, "from"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :heading, ::WsdlMapper::Dom::Name.get(nil, "heading"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :body, ::WsdlMapper::Dom::Name.get(nil, "body"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :attachments, ::WsdlMapper::Dom::Name.get(nil, "attachments"), ::WsdlMapper::Dom::Name.get(nil, "attachmentType"), array: true
end
RUBY

      assert_file_is "attachment_type_deserializer.rb", <<RUBY
require "deserializer_factory"
require "attachment_type"

AttachmentTypeDeserializer = ::DeserializerFactory.register(nil, "attachmentType", ::AttachmentType) do
  register_prop :name, ::WsdlMapper::Dom::Name.get(nil, "name"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
  register_prop :body, ::WsdlMapper::Dom::Name.get(nil, "body"), ::WsdlMapper::Dom::Name.get("http://www.w3.org/2001/XMLSchema", "string")
end
RUBY
    end
  end
end
