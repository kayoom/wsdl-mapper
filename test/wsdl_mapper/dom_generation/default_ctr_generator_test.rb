require 'test_helper'

require 'wsdl_mapper/dom_parsing/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/default_ctr_generator'

require 'wsdl_mapper/dom/property'

module DomGenerationTests
  module GeneratorTests
    class DefaultCtrGeneratorTest < GenerationTest
      include WsdlMapper::Generation
      include WsdlMapper::DomGeneration
      include WsdlMapper::Dom

      def generate(name)
        schema = TestHelper.parse_schema name
        generator = SchemaGenerator.new context, ctr_generator_factory: DefaultCtrGenerator
        generator.generate schema
      end

      def test_super_ctr
        generate 'basic_note_type_and_fancy_note_type_extension.xsd'

        assert_file_is 'fancy_note_type.rb', <<RUBY
require "note_type"

class FancyNoteType < ::NoteType
  attr_accessor :attachments

  def initialize(attachments: [], to: nil, from: nil, heading: nil, body: nil)
    super(to: to, from: from, heading: heading, body: body)
    @attachments = attachments
  end
end
RUBY
      end

      def test_super_super_ctr
        generate 'super_fancy_note_type.xsd'

        assert_file_is 'super_fancy_note_type.rb', <<RUBY
require "fancy_note_type"
require "date"

class SuperFancyNoteType < ::FancyNoteType
  attr_accessor :expires_at

  def initialize(expires_at: nil, attachments: [], to: nil, from: nil, heading: nil, body: nil)
    super(attachments: attachments, to: to, from: from, heading: heading, body: body)
    @expires_at = expires_at
  end
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

  def initialize(to: nil, from: nil, heading: nil, body: nil)
    @to = to
    @from = from
    @heading = heading
    @body = body
  end
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

  def initialize(to: nil, from: nil, heading: nil, body: nil, uuid: nil)
    @to = to
    @from = from
    @heading = heading
    @body = body

    @uuid = uuid
  end
end
RUBY
      end

      def test_simple_class_generation_with_default_values
        generate 'basic_note_type_with_defaults.xsd'

        assert_file_is 'note_type.rb', <<RUBY
require "date"

class NoteType
  attr_accessor :to
  attr_accessor :from
  attr_accessor :date
  attr_accessor :heading
  attr_accessor :body

  def initialize(to: [], from: "noreply@example.org", date: ::DateTime.parse("2015-10-27T13:05:01+01:00"), heading: nil, body: nil)
    @to = to
    @from = from
    @date = date
    @heading = heading
    @body = body
  end
end
RUBY
      end

      def test_simple_class_generation_with_required_single_value
        generate 'basic_order_type_with_required_address_type_enum.xsd'

        assert_file_is 'order_type.rb', <<RUBY
require "address_type"

class OrderType
  attr_accessor :name
  attr_accessor :street
  attr_accessor :type

  def initialize(name: nil, street: nil, type: ::AddressType.new)
    @name = name
    @street = street
    @type = type
  end
end
RUBY
      end

      def test_complex_type_with_simple_content_generation
        generate 'simple_money_type_with_currency_attribute.xsd'

        assert_file_is 'money_type.rb', <<RUBY
class MoneyType
  attr_accessor :content

  attr_accessor :currency

  def initialize(content, currency: nil)
    @content = content

    @currency = currency
  end
end
RUBY
      end
    end
  end
end

