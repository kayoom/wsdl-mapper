require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/documented_enum_generator'

module DomGenerationTests
  module GeneratorTests
    class DocumentedEnumGeneratorTest < GenerationTestCase
      include WsdlMapper::DomGeneration
      
      def generate name
        schema = TestHelper.parse_schema name
        generator = SchemaGenerator.new context, enum_generator_factory: DocumentedEnumGenerator
        generator.generate schema
      end

      def test_class_documentation
        generate 'address_type_enumeration_with_documentation.xsd'

        assert_file_is "address_type.rb", <<RUBY
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
        generate 'address_type_enumeration_with_value_documentation.xsd'

        assert_file_is "address_type.rb", <<RUBY
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
