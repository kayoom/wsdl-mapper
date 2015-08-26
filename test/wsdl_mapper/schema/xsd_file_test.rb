require 'test_helper'

require 'wsdl_mapper/schema/xsd_file'

class XsdFileTest < Minitest::Test
  def setup
    @file = WsdlMapper::Schema::XsdFile.new(TestHelper.get_fixture("w3_example.xsd"))
  end

  def test_that_it_can_load_a_simple_xsd_file
    assert_kind_of WSDL::XMLSchema::Schema, @file.root
  end

  def test_that_it_found_the_embedded_schema
    element_names = @file.root.collect_elements.map { |e| e.name.name }

    assert_includes element_names, "note"
  end
end
