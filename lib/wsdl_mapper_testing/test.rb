module WsdlMapperTesting
  class Test < Minitest::Test
    def create_test_module content
      test_module_name = 'TestModule' + SecureRandom.hex
      eval "module #{test_module_name}\n#{content}\nend"
      self.class.const_get test_module_name
    end
  end
end
