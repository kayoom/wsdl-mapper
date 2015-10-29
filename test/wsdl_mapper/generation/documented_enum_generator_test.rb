require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/generation/schema_generator'
require 'wsdl_mapper/generation/documented_enum_generator'

module GenerationTests
  module GeneratorTests
    class DocumentedEnumGeneratorTest < Minitest::Test
      include WsdlMapper::Generation

      def setup
        @tmp_path = TestHelper.get_tmp_path
      end

      def teardown
        @tmp_path.unlink
      end

      def test_class_documentation
        schema = TestHelper.parse_schema 'example_20.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, enum_generator_factory: DocumentedEnumGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("address_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
# This is some documentation for addressType.
#
# @xml_name addressType
class AddressType < ::String
  # @xml_value ship
  SHIP = new("ship").freeze

  # @xml_value bill
  BILL = new("bill").freeze

  Values = [
    SHIP,
    BILL
  ]
end
RUBY
      end

      def test_value_documentation
        schema = TestHelper.parse_schema 'example_21.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, enum_generator_factory: DocumentedEnumGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("address_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
# @xml_name addressType
class AddressType < ::String
  # This is some documentation for ship.
  #
  # @xml_value ship
  SHIP = new("ship").freeze

  # This is some documentation for bill.
  #
  # @xml_value bill
  BILL = new("bill").freeze

  Values = [
    SHIP,
    BILL
  ]
end
RUBY
      end
    end
  end
end
