require 'test_helper'

require 'wsdl_mapper/schema/parser'

module GenerationTests
  module GeneratorTests
    class SimpleTest < Minitest::Test
      def test_simple_class_generation
        schema = TestHelper.parse_schema 'example_1.xsd'



      end

    end
  end
end

