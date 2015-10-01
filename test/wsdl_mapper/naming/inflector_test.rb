require 'test_helper'

require 'wsdl_mapper/naming/inflector'

module NamingTests
  class InflectorTest < ::Minitest::Test
    include WsdlMapper::Naming::Inflector

    def test_camelize
      test_strings = [
        'foo_bar',
        'foo bar',
        ' foo bar ',
        'foo/bar',
        'fooBar'
      ]

      test_strings.each do |str|
        assert_equal 'FooBar', camelize(str)
      end
    end

    def test_underscore
      test_strings = [
        'FooBar',
        'Foo Bar',
        ' foo bar ',
        'foo/bar',
        'fooBar'
      ]

      test_strings.each do |str|
        assert_equal 'foo_bar', underscore(str)
      end
    end
  end
end
