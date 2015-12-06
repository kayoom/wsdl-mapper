require 'test_helper'

require 'wsdl_mapper/svc_generation/svc_generator'

module SvcDescParsingTests
  class OperationGeneratorTest < GenerationTest
    include WsdlMapper::SvcGeneration
    include WsdlMapper::Dom

    NS = 'http://example.org/schema'

    def generate(name)
      @desc = TestHelper.parse_wsdl name
      generator = SvcGenerator.new context
      generator.generate @desc
    end

    def test_operation_generation
      generate 'wsdls/price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price.rb', <<RUBY
require "wsdl_mapper/runtime/operation"

class PriceService
  class ProductPrices
    class GetProductPrice < ::WsdlMapper::Runtime::Operation

      def initialize(api, service, port)
        super(api, service, port)
        @_soap_action = "GetProductPrice"
        @_requires = [
          "credentials_type",
          "product_idtype",
          "variant_idtype",
          "price_inline_type",
          "s8r_type_directory",
          "price_service/product_prices/get_product_price/input_header",
          "price_service/product_prices/get_product_price/input_body",
          "price_service/product_prices/get_product_price/output_header",
          "price_service/product_prices/get_product_price/output_body",
          "price_service/product_prices/get_product_price/input_s8r",
          "price_service/product_prices/get_product_price/input_d10r",
          "price_service/product_prices/get_product_price/output_s8r",
          "price_service/product_prices/get_product_price/output_d10r"
        ]
      end

      def new_input(header: {}, body: {})
        super
        new_message(::PriceService::ProductPrices::GetProductPrice::InputHeader.new(**header), ::PriceService::ProductPrices::GetProductPrice::InputBody.new(**body))
      end

      def new_output(header: {}, body: {})
        super
        new_message(::PriceService::ProductPrices::GetProductPrice::OutputHeader.new(**header), ::PriceService::ProductPrices::GetProductPrice::OutputBody.new(**body))
      end

      def input_s8r
        super
        @input_s8r ||= ::PriceService::ProductPrices::GetProductPrice::InputS8r.new(::S8rTypeDirectory)
      end

      def output_s8r
        super
        @output_s8r ||= ::PriceService::ProductPrices::GetProductPrice::OutputS8r.new(::S8rTypeDirectory)
      end

      def input_d10r
        super
        @input_d10r ||= ::PriceService::ProductPrices::GetProductPrice::InputD10r
      end

      def output_d10r
        super
        @output_d10r ||= ::PriceService::ProductPrices::GetProductPrice::OutputD10r
      end
    end
  end
end
RUBY
    end

    def test_operation_input_header_generation_doc_literal
      generate 'wsdls/price_service_doc_literal.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/input_header.rb', <<RUBY
require "wsdl_mapper/runtime/header"

class PriceService
  class ProductPrices
    class GetProductPrice
      class InputHeader < ::WsdlMapper::Runtime::Header
        attr_accessor :credentials_user_and_password

        def initialize(credentials_user_and_password: nil)
          @credentials_user_and_password = credentials_user_and_password
        end
      end
    end
  end
end
RUBY
    end

    def test_operation_output_header_generation_doc_literal
      generate 'wsdls/price_service_doc_literal.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/output_header.rb', <<RUBY
require "wsdl_mapper/runtime/header"

class PriceService
  class ProductPrices
    class GetProductPrice
      class OutputHeader < ::WsdlMapper::Runtime::Header

        def initialize
        end
      end
    end
  end
end
RUBY
    end

    def test_operation_input_body_generation_doc_literal
      generate 'wsdls/price_service_doc_literal.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/input_body.rb', <<RUBY
require "wsdl_mapper/runtime/body"

class PriceService
  class ProductPrices
    class GetProductPrice
      class InputBody < ::WsdlMapper::Runtime::Body
        attr_accessor :product_idpart
        attr_accessor :variant_idpart

        def initialize(product_idpart: nil, variant_idpart: nil)
          @product_idpart = product_idpart
          @variant_idpart = variant_idpart
        end
      end
    end
  end
end
RUBY
    end

    def test_operation_output_body_generation_doc_literal
      generate 'wsdls/price_service_doc_literal.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/output_body.rb', <<RUBY
require "wsdl_mapper/runtime/body"

class PriceService
  class ProductPrices
    class GetProductPrice
      class OutputBody < ::WsdlMapper::Runtime::Body
        attr_accessor :price

        def initialize(price: nil)
          @price = price
        end
      end
    end
  end
end
RUBY
    end

    def test_operation_input_header_generation
      generate 'wsdls/price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/input_header.rb', <<RUBY
require "wsdl_mapper/runtime/header"

class PriceService
  class ProductPrices
    class GetProductPrice
      class InputHeader < ::WsdlMapper::Runtime::Header
        attr_accessor :credentials_user_and_password

        def initialize(credentials_user_and_password: nil)
          @credentials_user_and_password = credentials_user_and_password
        end
      end
    end
  end
end
RUBY
    end

    def test_operation_output_header_generation
      generate 'wsdls/price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/output_header.rb', <<RUBY
require "wsdl_mapper/runtime/header"

class PriceService
  class ProductPrices
    class GetProductPrice
      class OutputHeader < ::WsdlMapper::Runtime::Header

        def initialize
        end
      end
    end
  end
end
RUBY
    end

    def test_operation_input_body_generation
      generate 'wsdls/price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/input_body.rb', <<RUBY
require "wsdl_mapper/runtime/body"

class PriceService
  class ProductPrices
    class GetProductPrice
      class InputBody < ::WsdlMapper::Runtime::Body
        attr_accessor :product_idpart
        attr_accessor :variant_idpart

        def initialize(product_idpart: nil, variant_idpart: nil)
          @product_idpart = product_idpart
          @variant_idpart = variant_idpart
        end
      end
    end
  end
end
RUBY
    end

    def test_operation_output_body_generation
      generate 'wsdls/price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/output_body.rb', <<RUBY
require "wsdl_mapper/runtime/body"

class PriceService
  class ProductPrices
    class GetProductPrice
      class OutputBody < ::WsdlMapper::Runtime::Body
        attr_accessor :price

        def initialize(price: nil)
          @price = price
        end
      end
    end
  end
end
RUBY
    end
  end
end
