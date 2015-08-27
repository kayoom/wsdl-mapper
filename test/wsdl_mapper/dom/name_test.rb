require 'test_helper'

require 'wsdl_mapper/dom/name'

module DomTests
  class NameTest < Minitest::Test
    include WsdlMapper::Dom

    def test_equality
      name1 = Name.new 'foo', 'bar'
      name2 = Name.new 'foo', 'baz'
      name3 = Name.new nil, 'bar'
      name4 = Name.new 'foo', 'bar'

      refute_equal name1, name2
      refute_equal name1, name3
      assert_equal name1, name4
    end

    def test_hash_key_equality
      name1 = Name.new 'foo', 'bar'
      name2 = Name.new 'foo', 'bar'

      hash = {
        name1 => 'bam'
      }

      assert_equal 'bam', hash[name2]
    end
  end
end

