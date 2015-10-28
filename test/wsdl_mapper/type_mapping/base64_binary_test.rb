require 'test_helper'

require 'wsdl_mapper/type_mapping/base64_binary'

module TypeMappingTests
  class Base64BinaryTest < ::Minitest::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby
      io = Base64Binary.to_ruby "VGhpcyBpcyBhIHRlc3Q=\n"

      assert_equal "This is a test", io.read
      assert_equal Encoding::ASCII_8BIT, io.external_encoding
    end

    def test_to_xml
      io = StringIO.new "This is a test"
      encoded = Base64Binary.to_xml io

      assert_equal "VGhpcyBpcyBhIHRlc3Q=\n", encoded
    end

    def test_ruby_type
      assert_equal ::StringIO, Base64Binary.ruby_type
    end
  end
end
