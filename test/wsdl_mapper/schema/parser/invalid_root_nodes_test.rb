require 'test_helper'

require 'wsdl_mapper/schema/parser'

module SchemaTests
  module ParserTests
    class InvalidRootNodesTest < Minitest::Test
      include WsdlMapper::Schema
      include WsdlMapper::Dom

      def test_raise_error_on_invalid_root_node
        assert_raises(Parser::InvalidRootException) { TestHelper.parse_schema 'example_1_invalid_root_node.xsd' }
      end

      def test_raise_error_on_invalid_root_ns
        assert_raises(Parser::InvalidNsException) { TestHelper.parse_schema 'example_1_invalid_root_ns.xsd' }
      end

      def test_raise_error_on_invalid_root_ns_2
        assert_raises(Parser::InvalidNsException) { TestHelper.parse_schema 'example_1_invalid_root_ns_2.xsd' }
      end
    end
  end
end
