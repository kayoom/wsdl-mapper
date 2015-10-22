require 'test_helper'

require 'wsdl_mapper/type_mapping/uri'

module TypeMappingTests
  class UriTest < ::Minitest::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby

    end

    def test_to_xml
      uri = URI("http://example.com/?a=foo%20bar")
      assert_equal "http://example.com/?a=foo%20bar", Uri.to_xml(uri)

      uri = "http://example.com/?a=foo bar"
      assert_equal "http://example.com/?a=foo%20bar", Uri.to_xml(uri)
    end
  end
end
