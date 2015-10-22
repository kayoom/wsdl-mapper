require 'test_helper'

require 'wsdl_mapper/type_mapping/hex_binary'

module TypeMappingTests
  class HexBinaryTest < ::Minitest::Test
    include WsdlMapper::TypeMapping

    def test_to_ruby
      io = HexBinary.to_ruby "   5468697320697320612074657374   "

      assert_equal "This is a test", io.read
    end

    def test_to_xml
      io = StringIO.new "This is a test"
      encoded = HexBinary.to_xml io

      assert_equal "5468697320697320612074657374", encoded
    end
  end
end
