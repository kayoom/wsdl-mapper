require 'test_helper'

require 'wsdl_mapper/type_mapping/hex_binary'

module TypeMappingTests
  class HexBinaryTest < ::WsdlMapperTesting::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby
      io = HexBinary.to_ruby "   5468697320697320612074657374   "

      assert_equal "This is a test", io.read
      assert_equal Encoding::ASCII_8BIT, io.external_encoding
    end

    def test_to_xml
      io = StringIO.new "This is a test"
      encoded = HexBinary.to_xml io

      assert_equal "5468697320697320612074657374", encoded
    end

    def test_ruby_type
      assert_equal ::StringIO, HexBinary.ruby_type
    end
  end
end
