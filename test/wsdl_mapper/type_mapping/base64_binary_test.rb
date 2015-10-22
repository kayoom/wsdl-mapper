require 'test_helper'

require 'wsdl_mapper/type_mapping/base64_binary'

module TypeMappingTests
  class Base64BinaryTest < ::Minitest::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby
      io = Base64Binary.to_ruby "VGhpcyBpcyBhIHRlc3Q=\n"

      assert_equal "This is a test", io.read
    end

    def test_to_xml
      io = StringIO.new "This is a test"
      encoded = Base64Binary.to_xml io

      assert_equal "VGhpcyBpcyBhIHRlc3Q=\n", encoded
    end
  end
end
