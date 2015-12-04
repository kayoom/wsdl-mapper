require 'test_helper'

require 'wsdl_mapper/svc_generation/svc_generator'

module SvcDescParsingTests
  class OperationD10rGeneratorTest < GenerationTest
    include WsdlMapper::SvcGeneration
    include WsdlMapper::Dom

    NS = 'http://example.org/schema'
    SOAP_ENV = 'http://schemas.xmlsoap.org/soap/envelope/'

    def generate name
      @desc = TestHelper.parse_wsdl name
      generator = SvcGenerator.new context
      generator.generate @desc
    end

    def test_rpc_encoded_input_d10r
      generate 'price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/input_d10r.rb', <<RUBY
require "wsdl_mapper/svc_desc/envelope"
require "wsdl_mapper/deserializers/type_directory"
require "wsdl_mapper/deserializers/element_directory"
require "wsdl_mapper/deserializers/lazy_loading_deserializer"
require "wsdl_mapper/svc_desc/soap_type_directory"
require "wsdl_mapper/svc_desc/soap_element_directory"
require "d10r_type_directory"
require "d10r_element_directory"
require "price_service/product_prices/get_product_price/input_header"
require "price_service/product_prices/get_product_price/input_body"

class PriceService
  class ProductPrices
    class GetProductPrice
      InputTypeDirectory = ::WsdlMapper::Deserializers::TypeDirectory.new(::D10rTypeDirectory, ::WsdlMapper::SvcDesc::SoapTypeDirectory)
      InputHeaderDeserializer = InputTypeDirectory.register_type(["http://schemas.xmlsoap.org/soap/envelope/", "Header"], ::PriceService::ProductPrices::GetProductPrice::InputHeader) do
        register_prop(:credentials_user_and_password, ["http://example.org/schema", "UserAndPassword"], ["http://example.org/schema", "CredentialsType"])
      end
      InputBodyDeserializer = InputTypeDirectory.register_type(["http://schemas.xmlsoap.org/soap/envelope/", "Body"], ::PriceService::ProductPrices::GetProductPrice::InputBody) do
        register_wrapper(["http://example.org/schema", "GetProductPrice"])
        register_prop(:product_idpart, ["http://example.org/schema", "ProductIDPart"], ["http://example.org/schema", "ProductIDType"])
        register_prop(:variant_idpart, ["http://example.org/schema", "VariantIDPart"], ["http://example.org/schema", "VariantIDType"])
      end
      InputElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(InputTypeDirectory, ::D10rElementDirectory, ::WsdlMapper::SvcDesc::SoapElementDirectory)
      InputD10r = ::WsdlMapper::Deserializers::LazyLoadingDeserializer.new(InputElementDirectory)
    end
  end
end
RUBY
    end

    def test_doc_literal_input_d10r
      generate 'price_service_doc_literal.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/input_d10r.rb', <<RUBY
require "wsdl_mapper/svc_desc/envelope"
require "wsdl_mapper/deserializers/type_directory"
require "wsdl_mapper/deserializers/element_directory"
require "wsdl_mapper/deserializers/lazy_loading_deserializer"
require "wsdl_mapper/svc_desc/soap_type_directory"
require "wsdl_mapper/svc_desc/soap_element_directory"
require "d10r_type_directory"
require "d10r_element_directory"
require "price_service/product_prices/get_product_price/input_header"
require "price_service/product_prices/get_product_price/input_body"

class PriceService
  class ProductPrices
    class GetProductPrice
      InputTypeDirectory = ::WsdlMapper::Deserializers::TypeDirectory.new(::D10rTypeDirectory, ::WsdlMapper::SvcDesc::SoapTypeDirectory)
      InputHeaderDeserializer = InputTypeDirectory.register_type(["http://schemas.xmlsoap.org/soap/envelope/", "Header"], ::PriceService::ProductPrices::GetProductPrice::InputHeader) do
        register_prop(:credentials_user_and_password, ["http://example.org/schema", "UserAndPassword"], ["http://example.org/schema", "CredentialsInlineType"])
      end
      InputBodyDeserializer = InputTypeDirectory.register_type(["http://schemas.xmlsoap.org/soap/envelope/", "Body"], ::PriceService::ProductPrices::GetProductPrice::InputBody) do
        register_prop(:product_idpart, ["http://example.org/schema", "ProductID"], ["http://example.org/schema", "ProductIDInlineType"])
        register_prop(:variant_idpart, ["http://example.org/schema", "VariantID"], ["http://example.org/schema", "VariantIDType"])
      end
      InputElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(InputTypeDirectory, ::D10rElementDirectory, ::WsdlMapper::SvcDesc::SoapElementDirectory)
      InputD10r = ::WsdlMapper::Deserializers::LazyLoadingDeserializer.new(InputElementDirectory)
    end
  end
end
RUBY
    end

    def test_rpc_encoded_output_d10r
      generate 'price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/output_d10r.rb', <<RUBY
require "wsdl_mapper/svc_desc/envelope"
require "wsdl_mapper/deserializers/type_directory"
require "wsdl_mapper/deserializers/element_directory"
require "wsdl_mapper/deserializers/lazy_loading_deserializer"
require "wsdl_mapper/svc_desc/soap_type_directory"
require "wsdl_mapper/svc_desc/soap_element_directory"
require "d10r_type_directory"
require "d10r_element_directory"
require "price_service/product_prices/get_product_price/output_header"
require "price_service/product_prices/get_product_price/output_body"

class PriceService
  class ProductPrices
    class GetProductPrice
      OutputTypeDirectory = ::WsdlMapper::Deserializers::TypeDirectory.new(::D10rTypeDirectory, ::WsdlMapper::SvcDesc::SoapTypeDirectory)
      OutputHeaderDeserializer = OutputTypeDirectory.register_type(["http://schemas.xmlsoap.org/soap/envelope/", "Header"], ::PriceService::ProductPrices::GetProductPrice::OutputHeader) do
      end
      OutputBodyDeserializer = OutputTypeDirectory.register_type(["http://schemas.xmlsoap.org/soap/envelope/", "Body"], ::PriceService::ProductPrices::GetProductPrice::OutputBody) do
        register_wrapper(["http://example.org/schema", "GetProductPriceResponse"])
        register_prop(:price, ["http://example.org/schema", "Price"], ["http://example.org/schema", "PriceInlineType"])
      end
      OutputElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(OutputTypeDirectory, ::D10rElementDirectory, ::WsdlMapper::SvcDesc::SoapElementDirectory)
      OutputD10r = ::WsdlMapper::Deserializers::LazyLoadingDeserializer.new(OutputElementDirectory)
    end
  end
end
RUBY
    end
  end
end
