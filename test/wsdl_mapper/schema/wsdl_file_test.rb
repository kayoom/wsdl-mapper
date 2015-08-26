require 'test_helper'

require 'wsdl_mapper/schema/wsdl_file'

module SchemaTests
  class WsdlFileTest < Minitest::Test
    include WsdlMapper::Schema

    def setup
      @file = WsdlFile.new(TestHelper.get_fixture("w3_example.wsdl"))
    end

    def test_that_it_can_load_a_simple_wsdl_file
      assert_kind_of WSDL::Definitions, @file.root
    end

    def test_that_it_found_the_embedded_schema
      element_names = @file.root.collect_elements.map { |e| e.name.name }

      assert_includes element_names, "TradePriceRequest"
      assert_includes element_names, "TradePrice"
    end
  end
end
