require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/dom_generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/default_ctr_generator'

require 'wsdl_mapper/dom/property'

module DomGenerationTests
  module GeneratorTests
    class DefaultCtrGeneratorTest < Minitest::Test
      include WsdlMapper::DomGeneration
      include WsdlMapper::Dom

      def setup
        @tmp_path = TestHelper.get_tmp_path
      end

      def teardown
        @tmp_path.unlink
      end

      def test_simple_class_generation
        schema = TestHelper.parse_schema 'basic_note_type.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, ctr_generator_factory: DefaultCtrGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
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
        schema = TestHelper.parse_schema 'baisc_note_type_with_attribute.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, ctr_generator_factory: DefaultCtrGenerator

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
        schema = TestHelper.parse_schema 'basic_note_type_with_defaults.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, ctr_generator_factory: DefaultCtrGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("note_type.rb")

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
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
        schema = TestHelper.parse_schema 'basic_order_type_with_required_address_type_enum.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, ctr_generator_factory: DefaultCtrGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("order_type.rb")

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
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
    end
  end
end

