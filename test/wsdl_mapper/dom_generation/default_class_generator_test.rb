require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/dom_generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'

module DomGenerationTests
  module GeneratorTests
    class DefaultClassGeneratorTest < Minitest::Test
      def setup
        @tmp_path = TestHelper.get_tmp_path
      end

      def teardown
        @tmp_path.unlink
      end
      
      def test_empty_properties
        schema = TestHelper.parse_schema 'empty_note_type.xsd'
        context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
class NoteType
end
RUBY
      end

      def test_simple_class_generation
        schema = TestHelper.parse_schema 'basic_note_type.xsd'
        context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body
end
RUBY
      end

      def test_simple_class_generation_with_attributes
        schema = TestHelper.parse_schema 'basic_note_type_with_attribute.xsd'
        context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body

  attr_accessor :uuid
end
RUBY
      end

      def test_simple_class_generation_with_requires
        schema = TestHelper.parse_schema 'basic_note_type_with_date.xsd'
        context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
require "date"

class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :date
  attr_accessor :heading
  attr_accessor :body
end
RUBY
      end

      def test_sub_class_generation
        schema = TestHelper.parse_schema 'basic_note_type_and_fancy_note_type_extension.xsd'
        context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("fancy_note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
require "note_type"

class FancyNoteType < ::NoteType
  attr_accessor :attachments
end
RUBY
      end

      def test_simple_class_generation_with_require_of_property_types
        schema = TestHelper.parse_schema 'basic_order_type_with_referenced_address_type_enum.xsd'
        context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context, namer: WsdlMapper::Naming::DefaultNamer.new(module_path: %w[OrdersApi Types])

        result = generator.generate schema
        expected_file = @tmp_path.join("orders_api", "types", "order_type.rb")

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
require "orders_api/types/address_type"

module OrdersApi
  module Types
    class OrderType
      attr_accessor :name
      attr_accessor :street
      attr_accessor :type
    end
  end
end
RUBY
      end

      def test_soap_array_generation
        schema = TestHelper.parse_schema 'basic_note_type_with_soap_array.xsd'
        context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
require "attachments_array"

class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body
  attr_accessor :attachments
end
RUBY

        expected_file = @tmp_path.join("attachments_array.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
class AttachmentsArray < ::Array
end
RUBY
      end

      def test_complex_type_with_simple_content_generation
        schema = TestHelper.parse_schema 'simple_money_type_with_currency_attribute.xsd'
        context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("money_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
class MoneyType
  attr_accessor :content

  attr_accessor :currency
end
RUBY
      end

      def test_imported_schema
        schema = TestHelper.parse_schema 'basic_note_type_with_import.xsd'
        context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
require "attachment_type"

class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body
  attr_accessor :attachments
end
RUBY

        expected_file = @tmp_path.join("attachment_type.rb")
        assert File.exists? expected_file
      end

      def test_simple_class_generation_with_simple_types
        schema = TestHelper.parse_schema 'basic_note_type_with_referenced_simple_email_address_type.xsd'
        context = WsdlMapper::DomGeneration::Context.new @tmp_path.to_s
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
require "email_address_type"

class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body
end
RUBY

        expected_file = @tmp_path.join("email_address_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
class EmailAddressType
  attr_accessor :content
end
RUBY
      end
    end
  end
end

