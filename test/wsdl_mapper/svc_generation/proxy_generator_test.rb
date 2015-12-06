require 'test_helper'

require 'wsdl_mapper/svc_generation/svc_generator'

module SvcDescParsingTests
  class ProxyGeneratorTest < GenerationTest
    include WsdlMapper::SvcGeneration
    include WsdlMapper::Dom

    NS = 'http://example.org/schema'

    def generate(name)
      @desc = TestHelper.parse_wsdl name
      generator = SvcGenerator.new context
      generator.generate @desc
    end

    def test_proxy_generation
      generate 'wsdls/price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service/product_prices_proxy.rb', <<RUBY
require "wsdl_mapper/runtime/proxy"
require "price_service/product_prices"

class PriceService
  class ProductPricesProxy < ::WsdlMapper::Runtime::Proxy

    def get_product_price(body, **args)
      @_api._call(@_port.get_product_price, body, **args)
    end
  end
end
RUBY
    end
  end
end
