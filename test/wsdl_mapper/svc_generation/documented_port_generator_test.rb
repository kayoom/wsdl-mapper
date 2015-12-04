require 'test_helper'

require 'wsdl_mapper/svc_generation/documented_svc_generator'

module SvcDescParsingTests
  class DocumentedPortGeneratorTest < GenerationTest
    include WsdlMapper::SvcGeneration
    include WsdlMapper::Dom

    NS = 'http://example.org/schema'

    def generate(name)
      @desc = TestHelper.parse_wsdl name
      generator = DocumentedSvcGenerator.new context
      generator.generate @desc
    end

    def test_port_generation
      generate 'wsdls/price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service/product_prices.rb', <<RUBY
require "wsdl_mapper/runtime/port"

class PriceService
  class ProductPrices < ::WsdlMapper::Runtime::Port
    require "price_service/product_prices/get_product_price"

    # @!attribute get_product_price
    #   @return [::PriceService::ProductPrices::GetProductPrice]
    #   @soap_name GetProductPrice
    attr_reader :get_product_price

    def initialize(api, service)
      super(api, service)
      @_style = "rpc"
      @_transport = "http://schemas.xmlsoap.org/soap/http"
      @_soap_address = "http://example.org/api"
      @get_product_price = ::PriceService::ProductPrices::GetProductPrice.new(api, service, self)
      @_operations << @get_product_price
    end
  end
end
RUBY
    end
  end
end
