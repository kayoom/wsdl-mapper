require 'test_helper'

require 'wsdl_mapper/svc_generation/documented_svc_generator'

module SvcDescParsingTests
  class DocumentedServiceGeneratorTest < GenerationTest
    include WsdlMapper::SvcGeneration
    include WsdlMapper::Dom

    NS = 'http://example.org/schema'

    def generate(name)
      @desc = TestHelper.parse_wsdl name
      generator = DocumentedSvcGenerator.new context
      generator.generate @desc
    end

    def test_service_generation
      generate 'wsdls/price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service.rb', <<RUBY
require "wsdl_mapper/runtime/service"

class PriceService < ::WsdlMapper::Runtime::Service
  require "price_service/product_prices"

  # @!attribute product_prices
  #   @return [::PriceService::ProductPrices]
  #   @soap_name ProductPrices
  #   @soap_binding DefaultBinding
  attr_reader :product_prices

  def initialize(api)
    super(api)
    @product_prices = ::PriceService::ProductPrices.new(api, self)
    @_ports << @product_prices
  end
end
RUBY
    end
  end
end
