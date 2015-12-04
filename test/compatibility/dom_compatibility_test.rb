require 'test_helper'

require 'wsdl_mapper/dom_parsing/parser'

module SchemaTests
  class CompatibiltyTest < WsdlMapperTesting::Test
    include WsdlMapper::DomParsing
    include WsdlMapper::Dom

    def test_parsing_ebay_svc
      doc = TestHelper.get_xml_doc 'services/ebaySvc.xsd'
      parser = WsdlMapper::DomParsing::Parser.new

      schema = parser.parse doc

      assert_equal 0, parser.log_msgs.count
    end

    def test_parsing_plenty_114
      doc = TestHelper.get_xml_doc 'services/plenty_114.xsd'
      parser = WsdlMapper::DomParsing::Parser.new

      schema = parser.parse doc

      assert_equal 0, parser.log_msgs.count
    end

    def test_parsing_magento_v2
      doc = TestHelper.get_xml_doc 'services/magento_v2.xsd'
      parser = WsdlMapper::DomParsing::Parser.new

      schema = parser.parse doc

      assert_equal 0, parser.log_msgs.count
    end

    def test_parsing_tb_stock
      doc = TestHelper.get_xml_doc 'services/tb-stock_all_in_one.xsd'
      parser = WsdlMapper::DomParsing::Parser.new

      schema = parser.parse doc

      assert_equal 0, parser.log_msgs.count
    end

    def test_parsing_tb_cat
      doc = TestHelper.get_xml_doc 'services/tb-cat_1_2_import.xsd'
      parser = WsdlMapper::DomParsing::Parser.new import_resolver: DefaultResolver.new(File.dirname(__FILE__))

      schema = parser.parse doc

      assert_equal 0, parser.log_msgs.count
    end
  end
end

