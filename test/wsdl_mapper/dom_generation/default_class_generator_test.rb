require 'test_helper'

require 'wsdl_mapper/dom_parsing/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'

module DomGenerationTests
  module GeneratorTests
    class DefaultClassGeneratorTest < GenerationTest
      def generate(name)
        schema = get_schema name
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context
        generator.generate schema
      end

      def test_inline_complex_type
        generate 'basic_note_type_with_inline_complex_type.xsd'

        assert_file_is 'attachment_inline_type.rb', <<RUBY
class AttachmentInlineType
  attr_accessor :name
  attr_accessor :body
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
        generate 'basic_note_type_with_element_inline_complex_type.xsd'

        assert_file_is 'note_inline_type.rb', <<RUBY
class NoteInlineType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body
end
RUBY
      end

      def test_empty_properties
        generate 'empty_note_type.xsd'

        assert_file_is 'note_type.rb', <<RUBY
class NoteType
end
RUBY
      end

      def test_simple_class_generation
        generate 'basic_note_type.xsd'

        assert_file_is 'note_type.rb', <<RUBY
class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body
end
RUBY
      end

      def test_simple_class_generation_with_attributes
        generate 'basic_note_type_with_attribute.xsd'

        assert_file_is 'note_type.rb', <<RUBY
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
        generate 'basic_note_type_with_date.xsd'

        assert_file_is 'note_type.rb', <<RUBY
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
        generate 'basic_note_type_and_fancy_note_type_extension.xsd'

        assert_file_is 'fancy_note_type.rb', <<RUBY
require "note_type"

class FancyNoteType < ::NoteType
  attr_accessor :attachments
end
RUBY
      end

      def test_simple_class_generation_with_require_of_property_types
        schema = TestHelper.parse_schema 'basic_order_type_with_referenced_address_type_enum.xsd'
        context = WsdlMapper::Generation::Context.new @tmp_path.to_s
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context, namer: WsdlMapper::Naming::DefaultNamer.new(module_path: %w[OrdersApi Types])

        generator.generate schema
        assert_file_is 'orders_api', 'types', 'order_type.rb', <<RUBY
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
        generate 'basic_note_type_with_soap_array.xsd'

        assert_file_is 'note_type.rb', <<RUBY
require "attachments_array"

class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body
  attr_accessor :attachments
end
RUBY

        assert_file_is 'attachments_array.rb', <<RUBY
class AttachmentsArray < ::Array
end
RUBY
      end

      def test_complex_type_with_simple_content_generation
        generate 'simple_money_type_with_currency_attribute.xsd'

        assert_file_is 'money_type.rb', <<RUBY
class MoneyType
  attr_accessor :content

  attr_accessor :currency
end
RUBY
      end

      def test_imported_schema
        generate 'basic_note_type_with_import.xsd'

        assert_file_is 'note_type.rb', <<RUBY
require "attachment_type"

class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body
  attr_accessor :attachments
end
RUBY

        expected_file = @tmp_path.join('attachment_type.rb')
        assert File.exists? expected_file
      end

      def test_simple_class_generation_with_simple_types
        generate 'basic_note_type_with_referenced_simple_email_address_type.xsd'

        assert_file_is 'note_type.rb', <<RUBY
require "email_address_type"

class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :heading
  attr_accessor :body
end
RUBY

        assert_file_is 'email_address_type.rb', <<RUBY
class EmailAddressType
  attr_accessor :content
end
RUBY
      end
    end
  end
end

