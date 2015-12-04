require 'wsdl_mapper_testing/test'

module WsdlMapperTesting
  class ImplementationTest < WsdlMapperTesting::Test
    def assert_implements(abstract, implementation)
      impl_methods = implementation.public_methods

      abstract.public_methods.each do |method_name|
        assert_includes impl_methods, method_name, "Expected #{implementation} to define method #{method_name}."

        method = abstract.method method_name
        impl_method = implementation.method method_name
        assert_equal method.arity, impl_method.arity, "#{implementation}##{method_name} has wrong number of arguments (#{impl_method.arity} instead of #{method.arity})"
      end
    end
  end
end
