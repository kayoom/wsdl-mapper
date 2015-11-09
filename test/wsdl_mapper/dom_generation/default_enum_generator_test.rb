require 'test_helper'

require 'wsdl_mapper/dom_parsing/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'

module DomGenerationTests
  module GeneratorTests
    class DefaultEnumGeneratorTest < GenerationTestCase
      include WsdlMapper::DomGeneration

      def generate name
        schema = TestHelper.parse_schema name
        generator = SchemaGenerator.new context
        generator.generate schema
      end

      def test_simple_enum_generation
        generate 'address_type_enumeration.xsd'

        assert_file_is "address_type.rb", <<RUBY
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
