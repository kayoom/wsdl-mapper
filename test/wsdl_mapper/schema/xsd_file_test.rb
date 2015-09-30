require 'test_helper'

require 'wsdl_mapper/schema/xsd_file'

module SchemaTests
  class XsdFileTest < Minitest::Test
    include WsdlMapper::Schema

    def setup
    end

    def test_that_it_can_load_a_simple_xsd_file
      @file = XsdFile.new(TestHelper.get_fixture("w3_example.xsd"))

      assert_kind_of WSDL::XMLSchema::Schema, @file.schema
    end

    def test_that_it_found_the_embedded_schema
      @file = XsdFile.new(TestHelper.get_fixture("w3_example.xsd"))

      element_names = @file.schema.collect_elements.map { |e| e.name.name }

      assert_includes element_names, "note"
    end

    # def test_byebug
    #   skip
    #   doc = Nokogiri::XML::Document.parse(TestHelper.get_fixture("ms_cust_order_example.xsd"))
    #   require 'byebug'
    #   byebug
    # end
  end
end
