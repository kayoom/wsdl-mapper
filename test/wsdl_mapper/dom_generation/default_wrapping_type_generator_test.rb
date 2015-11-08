require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/default_ctr_generator'

module DomGenerationTests
  module GeneratorTests
    class DefaultWrappingTypeGeneratorTest < GenerationTestCase
      include WsdlMapper::DomGeneration

      def generate name
        schema = TestHelper.parse_schema name        
        generator = SchemaGenerator.new context
        generator.generate schema
      end

      # TODO: complex type with simple content!

      def test_generation
        generate 'simple_email_address_type.xsd'

        assert_file_is "email_address_type.rb", <<RUBY
class EmailAddressType
  attr_accessor :content
end
RUBY
      end
    end
  end
end

