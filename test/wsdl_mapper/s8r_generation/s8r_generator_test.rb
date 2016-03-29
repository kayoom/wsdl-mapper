require 'test_helper'

require 'wsdl_mapper/dom_parsing/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/s8r_generation/s8r_generator'

module S8rGenerationTests
  class S8rGeneratorTests < GenerationTest
    def generate(name)
      schema = get_schema name
      generator = WsdlMapper::S8rGeneration::S8rGenerator.new context
      generator.generate schema
    end

    def test_basic_empty_type
      generate 'empty_note_type.xsd'

      assert_file_is 's8r_type_directory.rb', <<RUBY
require "wsdl_mapper/serializers/type_directory"

S8rTypeDirectory = ::WsdlMapper::Serializers::TypeDirectory.new do
  register_type("::NoteType", "note_type_serializer", "::NoteTypeSerializer")
  register_element("::NoteType", [nil, "note"])
end
RUBY

      assert_file_is 'serializer.rb', <<RUBY
require "wsdl_mapper/serializers/serializer_factory"
require "s8r_type_directory"

Serializer = ::WsdlMapper::Serializers::SerializerFactory.new(::S8rTypeDirectory)
RUBY

      assert_file_is 'note_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class NoteTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = []
    x.complex([nil, "noteType"], name, attributes) do |x|
    end
  end
end
::S8rTypeDirectory.register_serializer("::NoteTypeSerializer", ::NoteTypeSerializer.new)
RUBY
    end

    def test_basic_type_with_inline_complex_type
      generate 'basic_note_type_with_inline_complex_type.xsd'

      assert_file_is 'note_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class NoteTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = []
    x.complex([nil, "noteType"], name, attributes) do |x|
      x.value_builtin([nil, "to"], obj.to, "string")
      x.value_builtin([nil, "from"], obj.from, "string")
      x.value_builtin([nil, "heading"], obj.heading, "string")
      x.value_builtin([nil, "body"], obj.body, "string")
      x.get("::AttachmentInlineType").build(x, obj.attachment, [nil, "attachment"])
    end
  end
end
::S8rTypeDirectory.register_serializer("::NoteTypeSerializer", ::NoteTypeSerializer.new)
RUBY

      assert_file_is 'attachment_inline_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class AttachmentInlineTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = []
    x.complex(nil, name, attributes) do |x|
      x.value_builtin([nil, "name"], obj.name, "string")
      x.value_builtin([nil, "body"], obj.body, "string")
    end
  end
end
::S8rTypeDirectory.register_serializer("::AttachmentInlineTypeSerializer", ::AttachmentInlineTypeSerializer.new)
RUBY
    end

    def test_basic_type_with_attribute
      generate 'basic_note_type_with_property_and_attribute.xsd'

      assert_file_is 'note_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class NoteTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = [
      [[nil, "uuid"], obj.uuid, "token"]
    ]
    x.complex([nil, "noteType"], name, attributes) do |x|
      x.value_builtin([nil, "to"], obj.to, "string")
      x.value_builtin([nil, "from"], obj.from, "string")
      x.value_builtin([nil, "heading"], obj.heading, "string")
      x.value_builtin([nil, "body"], obj.body, "string")
    end
  end
end
::S8rTypeDirectory.register_serializer("::NoteTypeSerializer", ::NoteTypeSerializer.new)
RUBY
    end

    def test_simple_type
      generate 'address_type_enumeration.xsd'

      assert_file_is 'address_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class AddressTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    x.simple([nil, "addressType"], name) do |x|
      x.text_builtin(obj, "token")
    end
  end
end
::S8rTypeDirectory.register_serializer("::AddressTypeSerializer", ::AddressTypeSerializer.new)
RUBY
    end

    def test_basic_type_with_target_namespace
      generate 'basic_note_type_with_target_namespace.xsd'

      assert_file_is 'note_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class NoteTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = []
    x.complex(["http://example.org/schema", "noteType"], name, attributes) do |x|
      x.value_builtin(["http://example.org/schema", "to"], obj.to, "string")
      x.value_builtin(["http://example.org/schema", "from"], obj.from, "string")
      x.value_builtin(["http://example.org/schema", "heading"], obj.heading, "string")
      x.value_builtin(["http://example.org/schema", "body"], obj.body, "string")
    end
  end
end
::S8rTypeDirectory.register_serializer("::NoteTypeSerializer", ::NoteTypeSerializer.new)
RUBY
    end

    def test_basic_type_with_import
      generate 'basic_note_type_with_import.xsd'

      assert_file_is 'note_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class NoteTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = []
    x.complex(["http://example.org/notes", "noteType"], name, attributes) do |x|
      x.value_builtin(["http://example.org/notes", "to"], obj.to, "string")
      x.value_builtin(["http://example.org/notes", "from"], obj.from, "string")
      x.value_builtin(["http://example.org/notes", "heading"], obj.heading, "string")
      x.value_builtin(["http://example.org/notes", "body"], obj.body, "string")
      obj.attachments.each do |itm|
        x.get("::AttachmentType").build(x, itm, ["http://example.org/notes", "attachments"])
      end
    end
  end
end
::S8rTypeDirectory.register_serializer("::NoteTypeSerializer", ::NoteTypeSerializer.new)
RUBY
    end

    def test_basic_type_with_array
      generate 'basic_note_type_with_attachments.xsd'

      assert_file_is 'note_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class NoteTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = []
    x.complex([nil, "noteType"], name, attributes) do |x|
      x.value_builtin([nil, "to"], obj.to, "string")
      x.value_builtin([nil, "from"], obj.from, "string")
      x.value_builtin([nil, "heading"], obj.heading, "string")
      x.value_builtin([nil, "body"], obj.body, "string")
      obj.attachments.each do |itm|
        x.value_builtin([nil, "attachments"], itm, "string")
      end
    end
  end
end
::S8rTypeDirectory.register_serializer("::NoteTypeSerializer", ::NoteTypeSerializer.new)
RUBY
    end

    def test_basic_type_with_array_simple_type
      generate 'basic_note_type_with_attachments_simple_type.xsd'

      assert_file_is 'note_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class NoteTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = []
    x.complex([nil, "noteType"], name, attributes) do |x|
      x.value_builtin([nil, "to"], obj.to, "string")
      x.value_builtin([nil, "from"], obj.from, "string")
      x.value_builtin([nil, "heading"], obj.heading, "string")
      x.value_builtin([nil, "body"], obj.body, "string")
      obj.attachments.each do |itm|
        x.get("::AttachmentType").build(x, itm, [nil, "attachments"])
      end
    end
  end
end
::S8rTypeDirectory.register_serializer("::NoteTypeSerializer", ::NoteTypeSerializer.new)
RUBY
    end

    def test_basic_type_with_reference
      generate 'basic_note_type_with_referenced_simple_email_address_type.xsd'

      assert_file_is 'note_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class NoteTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = []
    x.complex([nil, "noteType"], name, attributes) do |x|
      x.get("::EmailAddressType").build(x, obj.to, [nil, "to"])
      x.get("::EmailAddressType").build(x, obj.from, [nil, "from"])
      x.value_builtin([nil, "heading"], obj.heading, "string")
      x.value_builtin([nil, "body"], obj.body, "string")
    end
  end
end
::S8rTypeDirectory.register_serializer("::NoteTypeSerializer", ::NoteTypeSerializer.new)
RUBY

      assert_file_is 'email_address_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class EmailAddressTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    x.simple([nil, "emailAddressType"], name) do |x|
      x.text_builtin(obj, "string")
    end
  end
end
::S8rTypeDirectory.register_serializer("::EmailAddressTypeSerializer", ::EmailAddressTypeSerializer.new)
RUBY
    end

    def test_soap_array
      generate 'basic_note_type_with_soap_array.xsd'

      assert_file_is 'attachments_array_serializer.rb', <<RUBY
require "s8r_type_directory"

class AttachmentsArraySerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = [
      [[x.soap_enc, "arrayType"], [nil, "attachment[\#{obj.length}]"], "string"]
    ]
    x.complex([nil, "attachmentsArray"], name, attributes) do |x|
      obj.each do |itm|
        x.get("::Attachment").build(x, itm, [nil, "item"])
      end
    end
  end
end
::S8rTypeDirectory.register_serializer("::AttachmentsArraySerializer", ::AttachmentsArraySerializer.new)
RUBY
    end

    def test_soap_array_simple
      generate 'basic_note_type_with_soap_array_simple.xsd'

      assert_file_is 'attachments_array_serializer.rb', <<RUBY
require "s8r_type_directory"

class AttachmentsArraySerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = [
      [[x.soap_enc, "arrayType"], [nil, "attachment[\#{obj.length}]"], "string"]
    ]
    x.complex([nil, "attachmentsArray"], name, attributes) do |x|
      obj.each do |itm|
        x.get("::Attachment").build(x, itm, [nil, "item"])
      end
    end
  end
end
::S8rTypeDirectory.register_serializer("::AttachmentsArraySerializer", ::AttachmentsArraySerializer.new)
RUBY
    end

    def test_soap_array_builtin
      generate 'basic_note_type_with_soap_array_builtin.xsd'

      assert_file_is 'attachments_array_serializer.rb', <<RUBY
require "s8r_type_directory"

class AttachmentsArraySerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = [
      [[x.soap_enc, "arrayType"], ["http://www.w3.org/2001/XMLSchema", "string[\#{obj.length}]"], "string"]
    ]
    x.complex([nil, "attachmentsArray"], name, attributes) do |x|
      obj.each do |itm|
        x.value_builtin([nil, "item"], itm, "string")
      end
    end
  end
end
::S8rTypeDirectory.register_serializer("::AttachmentsArraySerializer", ::AttachmentsArraySerializer.new)
RUBY
    end

    def test_complex_type_with_simple_content
      generate 'simple_money_type_with_currency_attribute.xsd'

      assert_file_is 'money_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class MoneyTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = [
      [[nil, "currency"], obj.currency, "token"]
    ]
    x.complex([nil, "moneyType"], name, attributes) do |x|
      x.text_builtin(obj.content, "float")
    end
  end
end
::S8rTypeDirectory.register_serializer("::MoneyTypeSerializer", ::MoneyTypeSerializer.new)
RUBY
    end

    def test_basic_type_with_properties
      generate 'basic_note_type.xsd'

      assert_file_is 'note_type_serializer.rb', <<RUBY
require "s8r_type_directory"

class NoteTypeSerializer

  def build(x, obj, name)
    return if obj.nil?
    attributes = []
    x.complex([nil, "noteType"], name, attributes) do |x|
      x.value_builtin([nil, "to"], obj.to, "string")
      x.value_builtin([nil, "from"], obj.from, "string")
      x.value_builtin([nil, "heading"], obj.heading, "string")
      x.value_builtin([nil, "body"], obj.body, "string")
    end
  end
end
::S8rTypeDirectory.register_serializer("::NoteTypeSerializer", ::NoteTypeSerializer.new)
RUBY
    end

    def test_simple_s8r_generation_with_modules
      schema = TestHelper.parse_schema 'basic_note_type.xsd'
      context = WsdlMapper::Generation::Context.new @tmp_path.to_s
      generator = WsdlMapper::S8rGeneration::S8rGenerator.new context, namer: WsdlMapper::Naming::DefaultNamer.new(module_path: %w[NotesApi S8r])

      result = generator.generate schema

      expected_file = @tmp_path.join('notes_api', 's8r', 'note_type_serializer.rb')
      assert File.exists? expected_file
      assert_includes result.files, expected_file

      generated_class = File.read expected_file
      assert_equal <<RUBY, generated_class
require "notes_api/s8r/s8r_type_directory"

module NotesApi
  module S8r
    class NoteTypeSerializer

      def build(x, obj, name)
        return if obj.nil?
        attributes = []
        x.complex([nil, "noteType"], name, attributes) do |x|
          x.value_builtin([nil, "to"], obj.to, "string")
          x.value_builtin([nil, "from"], obj.from, "string")
          x.value_builtin([nil, "heading"], obj.heading, "string")
          x.value_builtin([nil, "body"], obj.body, "string")
        end
      end
    end
  end
end
::NotesApi::S8r::S8rTypeDirectory.register_serializer("::NotesApi::S8r::NoteTypeSerializer", ::NotesApi::S8r::NoteTypeSerializer.new)
RUBY

      root_node = result.module_tree.first
      assert_equal 'NotesApi', root_node.type_name.module_name
      middle_node = root_node.children.first
      assert_equal 'S8r', middle_node.type_name.module_name
      type_node = middle_node.children.first
      assert_equal 'NoteTypeSerializer', type_node.type_name.class_name

      expected_file = @tmp_path.join('notes_api', 's8r.rb')
      assert File.exists? expected_file

      generated_file = File.read expected_file
      assert_equal <<RUBY, generated_file
require "notes_api/s8r/note_type_serializer"
RUBY

      expected_file = @tmp_path.join('notes_api.rb')
      assert File.exists? expected_file

      generated_file = File.read expected_file
      assert_equal <<RUBY, generated_file
require "notes_api/s8r"
RUBY
    end
  end
end
