require 'test_helper'

require 'wsdl_mapper/schema/parser'

module SchemaTests
  class CompatibiltyTest < Minitest::Test
    include WsdlMapper::Schema
    include WsdlMapper::Dom

    def test_parsing_ebay_svc
      doc = TestHelper.get_xml_doc 'ebaySvc.xsd'
      parser = WsdlMapper::Schema::Parser.new

      schema = parser.parse doc

      assert_equal 0, parser.log_msgs.count
    end

    def test_parsing_plenty_114
      doc = TestHelper.get_xml_doc 'plenty_114.xsd'
      parser = WsdlMapper::Schema::Parser.new

      schema = parser.parse doc

      assert_equal 0, parser.log_msgs.count
    end

    def test_parsing_magento_v2
      doc = TestHelper.get_xml_doc 'magento_v2.xsd'
      parser = WsdlMapper::Schema::Parser.new

      schema = parser.parse doc

      assert_equal 0, parser.log_msgs.count
    end
  end
end

