require 'test_helper'

require 'wsdl_mapper/naming/inflector'

module NamingTests
  class InflectorTest < ::Minitest::Test
    include WsdlMapper::Naming::Inflector

    def test_camelize
      test_strings = [
        'foo1_bar',
        'foo1 bar',
        ' foo 1 bar ',
        'foo1/bar',
        'foo1Bar'
      ]

      test_strings.each do |str|
        assert_equal 'Foo1Bar', camelize(str), "Expected camelize(#{str}) to return Foo1Bar"
      end
    end

    def test_underscore
      test_strings = [
        'Foo1Bar',
        'Foo1 Bar',
        ' foo1 bar ',
        'foo1/bar',
        'foo1Bar'
      ]

      test_strings.each do |str|
        assert_equal 'foo1_bar', underscore(str)
      end
    end
  end
end
