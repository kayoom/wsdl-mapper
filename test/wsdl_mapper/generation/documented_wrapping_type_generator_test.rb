require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/generation/schema_generator'
require 'wsdl_mapper/generation/documented_wrapping_type_generator'

module GenerationTests
  module GeneratorTests
    class DocumentedWrappingTypeGeneratorTest < Minitest::Test
      include WsdlMapper::Generation

      def setup
        @tmp_path = TestHelper.get_tmp_path
      end

      def teardown
        @tmp_path.unlink
      end

      def test_generation
        schema = TestHelper.parse_schema 'simple_email_address_type_with_documentation.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context, wrapping_type_generator_factory: DocumentedWrappingTypeGenerator

        result = generator.generate schema

        expected_file = @tmp_path.join("email_address_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
# This is some documentation.
#
# @xml_name emailAddressType
class EmailAddressType
  attr_accessor :value
end
RUBY
      end
    end
  end
end

