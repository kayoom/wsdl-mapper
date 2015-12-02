require 'test_helper'

require 'wsdl_mapper/svc_generation/svc_generator'

module SvcDescParsingTests
  class OperationD10rGeneratorTest < GenerationTest
    include WsdlMapper::SvcGeneration
    include WsdlMapper::Dom

    NS = 'http://example.org/schema'
    SOAP_ENV = 'http://www.w3.org/2001/12/soap-envelope'

    def generate name
      @desc = TestHelper.parse_wsdl name
      generator = SvcGenerator.new context
      generator.generate @desc
    end

    ### Header ###
    def test_encoded_input_header_d10r
      skip
      generate 'price_service_rpc_encoded.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_d10r.rb', <<RUBY
RUBY
    end

    def test_literal_input_header_with_element_d10r
      skip
      generate 'price_service_doc_literal.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_d10r.rb', <<RUBY
RUBY
    end

    def test_literal_input_header_with_type_d10r
      skip
      generate 'price_service_doc_literal_type.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_d10r.rb', <<RUBY
RUBY
    end


    ### Body ###
    #### RPC ####

    def test_rpc_encoded_input_body_d10r
      skip
      generate 'price_service_rpc_encoded.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_d10r.rb', <<RUBY
RUBY
    end

    def test_rpc_literal_input_body_d10r
      skip
      generate 'price_service_rpc_literal.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_d10r.rb', <<RUBY
RUBY
    end

    #### Document ####

    def test_doc_encoded_input_body_d10r
      skip
      generate 'price_service_doc_encoded.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_d10r.rb', <<RUBY
RUBY
    end

    def test_doc_literal_input_body_with_type_d10r
      skip
      generate 'price_service_doc_literal_type.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_d10r.rb', <<RUBY
RUBY
    end

    def test_doc_literal_input_body_with_elements_d10r
      skip
      generate 'price_service_doc_literal.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_d10r.rb', <<RUBY
RUBY
    end
  end
end
