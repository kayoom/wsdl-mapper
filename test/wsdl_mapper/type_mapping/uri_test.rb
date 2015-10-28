require 'test_helper'

require 'wsdl_mapper/type_mapping/uri'

module TypeMappingTests
  class UriTest < ::Minitest::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby
      uri = Uri.to_ruby("http://example.com/?a=foo%20bar")

      assert_kind_of URI, uri
      assert_equal URI("http://example.com/?a=foo%20bar"), uri
    end

    def test_to_xml
      uri = URI("http://example.com/?a=foo%20bar")
      assert_equal "http://example.com/?a=foo%20bar", Uri.to_xml(uri)

      uri = "http://example.com/?a=foo bar"
      assert_equal "http://example.com/?a=foo%20bar", Uri.to_xml(uri)
    end

    def test_ruby_type
      assert_equal ::String, Uri.ruby_type
    end
  end
end
