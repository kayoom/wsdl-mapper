require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/dom_generation/context'
require 'wsdl_mapper/s8r_generation/s8r_generator'

module S8rGenerationTests
  class S8rGeneratorTests < ::Minitest::Test
    def setup
      @tmp_path = TestHelper.get_tmp_path
    end

    def teardown
      @tmp_path.unlink
    end

    def test_basic_empty_type
      schema = TestHelper.parse_schema 'empty_note_type.xsd'
      context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
      generator = WsdlMapper::S8rGeneration::S8rGenerator.new context

      result = generator.generate schema

      expected_file = @tmp_path.join("note_type_serializer.rb")
      assert File.exists? expected_file

      generated_class = File.read expected_file
      assert_equal <<RUBY, generated_class
class NoteTypeSerializer

  def build(x, obj)
    attributes = []
    x.complex(nil, "noteType", attributes) do |x|
    end
  end
end
RUBY
    end

    def test_basic_type_with_attribute
      schema = TestHelper.parse_schema 'basic_note_type_with_property_and_attribute.xsd'
      context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
      generator = WsdlMapper::S8rGeneration::S8rGenerator.new context

      result = generator.generate schema

      expected_file = @tmp_path.join("note_type_serializer.rb")
      assert File.exists? expected_file

      generated_class = File.read expected_file
      assert_equal <<RUBY, generated_class
class NoteTypeSerializer

  def build(x, obj)
    attributes = [
      [nil, "uuid", obj.uuid, "token"]
    ]
    x.complex(nil, "noteType", attributes) do |x|
      x.value_builtin(nil, "to", obj.to, "string")
      x.value_builtin(nil, "from", obj.from, "string")
      x.value_builtin(nil, "heading", obj.heading, "string")
      x.value_builtin(nil, "body", obj.body, "string")
    end
  end
end
RUBY
    end

    def test_simple_type
      schema = TestHelper.parse_schema 'address_type_enumeration.xsd'
      context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
      generator = WsdlMapper::S8rGeneration::S8rGenerator.new context

      result = generator.generate schema

      expected_file = @tmp_path.join("address_type_serializer.rb")
      assert File.exists? expected_file

      generated_class = File.read expected_file
      assert_equal <<RUBY, generated_class
class AddressTypeSerializer

  def build(x, obj)
    x.simple(nil, "addressType") do |x|
      x.text_builtin(obj, "token")
    end
  end
end
RUBY
    end

    def test_basic_type_with_target_namespace
      schema = TestHelper.parse_schema 'basic_note_type_with_target_namespace.xsd'
      context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
      generator = WsdlMapper::S8rGeneration::S8rGenerator.new context

      result = generator.generate schema

      expected_file = @tmp_path.join("note_type_serializer.rb")
      assert File.exists? expected_file

      generated_class = File.read expected_file
      assert_equal <<RUBY, generated_class
class NoteTypeSerializer

  def build(x, obj)
    attributes = []
    x.complex("http://example.org/schema", "noteType", attributes) do |x|
      x.value_builtin("http://example.org/schema", "to", obj.to, "string")
      x.value_builtin("http://example.org/schema", "from", obj.from, "string")
      x.value_builtin("http://example.org/schema", "heading", obj.heading, "string")
      x.value_builtin("http://example.org/schema", "body", obj.body, "string")
    end
  end
end
RUBY
    end

#     def test_basic_type_with_import
#       schema = TestHelper.parse_schema 'basic_note_type_with_import.xsd'
#       context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
#       generator = WsdlMapper::S8rGeneration::S8rGenerator.new context
#
#       result = generator.generate schema
#       expected_file = @tmp_path.join("note_type_serializer.rb")
#       assert File.exists? expected_file
#
#       generated_class = File.read expected_file
#       assert_equal <<RUBY, generated_class
# class NoteTypeSerializer
#
#   def build(x, obj)
#     attributes = []
#     x.complex("http://example.org/notes", "noteType", attributes) do |x|
#       x.value_builtin(nil, "to", obj.to, "string")
#       x.value_builtin(nil, "from", obj.from, "string")
#       x.value_builtin(nil, "heading", obj.heading, "string")
#       x.value_builtin(nil, "body", obj.body, "string")
#     end
#   end
# end
# RUBY
#     end

    def test_basic_type_with_reference
      schema = TestHelper.parse_schema 'basic_note_type_with_referenced_simple_email_address_type.xsd'
      context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
      generator = WsdlMapper::S8rGeneration::S8rGenerator.new context

      result = generator.generate schema

      expected_file = @tmp_path.join("note_type_serializer.rb")
      assert File.exists? expected_file

      generated_class = File.read expected_file
      assert_equal <<RUBY, generated_class
class NoteTypeSerializer

  def build(x, obj)
    attributes = []
    x.complex(nil, "noteType", attributes) do |x|
      x.get("email_address_type_serializer").build(x, obj.to)
      x.get("email_address_type_serializer").build(x, obj.from)
      x.value_builtin(nil, "heading", obj.heading, "string")
      x.value_builtin(nil, "body", obj.body, "string")
    end
  end
end
RUBY

      expected_file = @tmp_path.join("email_address_type_serializer.rb")
      assert File.exists? expected_file

      generated_class = File.read expected_file
      assert_equal <<RUBY, generated_class
class EmailAddressTypeSerializer

  def build(x, obj)
    x.simple(nil, "emailAddressType") do |x|
      x.text_builtin(obj, "string")
    end
  end
end
RUBY
    end

    def test_soap_array
      schema = TestHelper.parse_schema 'basic_note_type_with_soap_array.xsd'
      context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
      generator = WsdlMapper::S8rGeneration::S8rGenerator.new context

      result = generator.generate schema
      expected_file = @tmp_path.join("attachments_array_serializer.rb")
      assert File.exists? expected_file

      generated_class = File.read expected_file
      assert_equal <<RUBY, generated_class
class AttachmentsArraySerializer

  def build(x, obj)
    attributes = [
      [x.soap_enc, "arrayType", "attachment[\#{obj.length}]", "string"]
    ]
    x.complex(nil, "attachmentsArray", attributes) do |x|
      obj.each do |itm|
        x.get("attachment_serializer").build(x, itm)
      end
    end
  end
end
RUBY
    end

    def test_complex_type_with_simple_content
      schema = TestHelper.parse_schema 'simple_money_type_with_currency_attribute.xsd'
      context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
      generator = WsdlMapper::S8rGeneration::S8rGenerator.new context

      result = generator.generate schema

      expected_file = @tmp_path.join("money_type_serializer.rb")
      assert File.exists? expected_file

      generated_class = File.read expected_file
      assert_equal <<RUBY, generated_class
class MoneyTypeSerializer

  def build(x, obj)
    attributes = [
      [nil, "currency", obj.currency, "token"]
    ]
    x.complex(nil, "moneyType", attributes) do |x|
      x.text_builtin(obj.content, "float")
    end
  end
end
RUBY
    end

    def test_basic_type_with_properties
      schema = TestHelper.parse_schema 'basic_note_type.xsd'
      context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
      generator = WsdlMapper::S8rGeneration::S8rGenerator.new context

      result = generator.generate schema

      expected_file = @tmp_path.join("note_type_serializer.rb")
      assert File.exists? expected_file

      generated_class = File.read expected_file
      assert_equal <<RUBY, generated_class
class NoteTypeSerializer

  def build(x, obj)
    attributes = []
    x.complex(nil, "noteType", attributes) do |x|
      x.value_builtin(nil, "to", obj.to, "string")
      x.value_builtin(nil, "from", obj.from, "string")
      x.value_builtin(nil, "heading", obj.heading, "string")
      x.value_builtin(nil, "body", obj.body, "string")
    end
  end
end
RUBY
    end
  end
end
