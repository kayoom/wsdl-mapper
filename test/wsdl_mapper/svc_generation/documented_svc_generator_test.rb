require 'test_helper'

require 'wsdl_mapper/svc_generation/documented_svc_generator'

module SvcDescParsingTests
  class DocumentedSvcGeneratorTest < GenerationTest
    include WsdlMapper::SvcGeneration
    include WsdlMapper::Dom

    NS = 'http://example.org/schema'

    def generate name
      @desc = TestHelper.parse_wsdl name
      generator = DocumentedSvcGenerator.new context
      generator.generate @desc
    end

    def test_api_generation
      generate 'wsdls/price_service_rpc_encoded.wsdl'

      assert_file_is 'api.rb', <<RUBY
require "wsdl_mapper/runtime/api"

require "price_service"

class Api < ::WsdlMapper::Runtime::Api
  # @!attribute price_service
  #   @return [::PriceService]
  #   @soap_name PriceService
  attr_reader :price_service

  def initialize(options = {})
    super(options)
    @price_service = ::PriceService.new(self)
    @_services << @price_service
  end
end
RUBY
    end
  end
end
