require 'test_helper'

require 'wsdl_mapper/dom_parsing/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/documented_wrapping_type_generator'

module DomGenerationTests
  module GeneratorTests
    class DocumentedWrappingTypeGeneratorTest < GenerationTest
      include WsdlMapper::DomGeneration

      def generate(name)
        schema = TestHelper.parse_schema name
        generator = SchemaGenerator.new context, wrapping_type_generator_factory: DocumentedWrappingTypeGenerator
        generator.generate schema
      end

      def test_generation
        generate 'simple_email_address_type_with_documentation.xsd'

        assert_file_is "email_address_type.rb", <<RUBY
# This is some documentation.
#
# @xml_name emailAddressType
class EmailAddressType
  attr_accessor :content
end
RUBY
      end
    end
  end
end

