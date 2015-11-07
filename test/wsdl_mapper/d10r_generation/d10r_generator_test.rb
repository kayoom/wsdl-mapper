require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
# require 'wsdl_mapper/d10r_generation/d10r_generator'

module D10rGenerationTests
  class D10rGeneratorTests < ::Minitest::Test
    def setup
      @tmp_path = TestHelper.get_tmp_path
    end

    def teardown
      @tmp_path.unlink
    end
  end
end
