require 'wsdl_mapper_testing/schema_test'

module WsdlMapperTesting
  class GenerationTest < SchemaTest
    def setup
      @tmp_path = TestHelper.get_tmp_path
    end

    def teardown
      @tmp_path.unlink
    end

    def tmp_path
      @tmp_path
    end

    def path_for *name
      tmp_path.join *name
    end

    def assert_file_exists *name
      path = tmp_path.join *name
      assert File.exist?(path), "Expected file #{name * '/'} to exist."
    end

    def assert_file_is *name, expected
      assert_file_exists *name
      assert_equal expected, file(*name)
    end

    def assert_file_contains *name, expected
      assert_file_exists *name
      content = file *name
      assert content.include?(expected.strip), "Expected\n\n#{content}\n\n to include\n\n#{expected}\n"
    end

    def file *name
      File.read tmp_path.join *name
    end

    def context
      @context ||= WsdlMapper::Generation::Context.new @tmp_path.to_s
    end
  end
end
