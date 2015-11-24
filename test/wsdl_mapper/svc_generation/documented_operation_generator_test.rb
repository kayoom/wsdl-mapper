require 'test_helper'

require 'wsdl_mapper/svc_generation/documented_svc_generator'

module SvcDescParsingTests
  class DocumentedOperationGeneratorTest < GenerationTest
    include WsdlMapper::SvcGeneration
    include WsdlMapper::Dom

    NS = 'http://example.org/schema'

    def generate name
      @desc = TestHelper.parse_wsdl name
      generator = DocumentedSvcGenerator.new context
      generator.generate @desc
    end

    def test_operation_input_header_generation_doc_literal
      generate 'price_service_doc_literal.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/input_header.rb', <<RUBY
require "wsdl_mapper/runtime/header"

class PriceService
  class ProductPrices
    class GetProductPrice
      class InputHeader < ::WsdlMapper::Runtime::Header
        # @!attribute credentials_user_and_password
        #   @return [::CredentialsInlineType]
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
      generate 'price_service_doc_literal.wsdl'

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
      generate 'price_service_doc_literal.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/input_body.rb', <<RUBY
require "wsdl_mapper/runtime/body"

class PriceService
  class ProductPrices
    class GetProductPrice
      class InputBody < ::WsdlMapper::Runtime::Body
        # @!attribute product_idpart
        #   @return [::ProductIDInlineType]
        attr_accessor :product_idpart

        # @!attribute variant_idpart
        #   @return [::VariantIDType]
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
      generate 'price_service_doc_literal.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/output_body.rb', <<RUBY
require "wsdl_mapper/runtime/body"

class PriceService
  class ProductPrices
    class GetProductPrice
      class OutputBody < ::WsdlMapper::Runtime::Body
        # @!attribute price
        #   @return [::PriceInlineType]
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
      generate 'price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/input_header.rb', <<RUBY
require "wsdl_mapper/runtime/header"

class PriceService
  class ProductPrices
    class GetProductPrice
      class InputHeader < ::WsdlMapper::Runtime::Header
        # @!attribute credentials_user_and_password
        #   @return [::CredentialsInlineType]
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
      generate 'price_service_rpc_encoded.wsdl'

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
      generate 'price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/input_body.rb', <<RUBY
require "wsdl_mapper/runtime/body"

class PriceService
  class ProductPrices
    class GetProductPrice
      class InputBody < ::WsdlMapper::Runtime::Body
        # @!attribute product_idpart
        #   @return [::ProductIDInlineType]
        attr_accessor :product_idpart

        # @!attribute variant_idpart
        #   @return [::VariantIDType]
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
      generate 'price_service_rpc_encoded.wsdl'

      assert_file_is 'price_service/product_prices/get_product_price/output_body.rb', <<RUBY
require "wsdl_mapper/runtime/body"

class PriceService
  class ProductPrices
    class GetProductPrice
      class OutputBody < ::WsdlMapper::Runtime::Body
        # @!attribute price
        #   @return [::PriceInlineType]
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
