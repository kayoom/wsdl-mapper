require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'

module DomGenerationTests
  module GeneratorTests
    class DefaultEnumGeneratorTest < Minitest::Test
      def setup
        @tmp_path = TestHelper.get_tmp_path
      end

      def teardown
        @tmp_path.unlink
      end

      def test_simple_enum_generation
        schema = TestHelper.parse_schema 'address_type_enumeration.xsd'
        context = WsdlMapper::Generation::Context.new @tmp_path.to_s
        generator = WsdlMapper::DomGeneration::SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("address_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
class AddressType < ::String
  SHIP = new("ship").freeze
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
