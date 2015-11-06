require 'test_helper'

require 'wsdl_mapper/dom/validator'
require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/dom/simple_type'
require 'wsdl_mapper/dom/builtin_type'
require 'wsdl_mapper/dom/schema'

module DomTests
  class ValidatorTest < Minitest::Test
    include WsdlMapper::Dom

    def test_invalid_root_of_simple_types
      schema = Schema.new
      a = SimpleType.new Name.get(nil, 'a')
      b = SimpleType.new Name.get(nil, 'b')
      a.base = b
      schema.add_type a
      schema.add_type b

      validator = Validator.new schema
      results = validator.validate

      error = results.first
      refute_nil error
      assert_equal a, error.element
      assert_equal :invalid_root, error.msg
    end
  end
end
