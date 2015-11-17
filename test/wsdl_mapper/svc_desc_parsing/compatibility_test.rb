require 'test_helper'

require 'wsdl_mapper/svc_desc_parsing/parser'

module SvcDescParsingTests
  class ParserTest < Minitest::Test
    include WsdlMapper::SvcDescParsing
    include WsdlMapper::Dom

    def test_parsing_ebay_svc
      doc = TestHelper.get_xml_doc 'ebaySvc.wsdl'
      parser = Parser.new

      parser.parse doc

      assert_equal 0, parser.log_msgs.count
    end

    def test_parsing_plenty_114
      doc = TestHelper.get_xml_doc 'plenty_114.wsdl'
      parser = Parser.new

      parser.parse doc

      assert_equal 0, parser.log_msgs.count
    end

    def test_parsing_magento_v2
      doc = TestHelper.get_xml_doc 'magento_v2.wsdl'
      parser = Parser.new

      parser.parse doc

      assert_equal 0, parser.log_msgs.count
    end

    # focus
    def test_parsing_cdiscount
      skip
      doc = TestHelper.get_xml_doc 'cdiscount.wsdl'
      parser = Parser.new

      parser.parse doc

      assert_equal 0, parser.log_msgs.count
    end
  end
end
