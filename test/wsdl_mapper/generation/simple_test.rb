require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/generation/generator'

module GenerationTests
  module GeneratorTests
    class SimpleTest < Minitest::Test
      def setup
        @tmp_path = TestHelper.get_tmp_path
      end

      def teardown
        @tmp_path.unlink
      end

      def test_simple_class_generation
        schema = TestHelper.parse_schema 'example_1.xsd'
        context = WsdlMapper::Generation::Context.new @tmp_path.to_s
        generator = WsdlMapper::Generation::Generator.new context

        result = generator.generate schema
      end
    end
  end
end

