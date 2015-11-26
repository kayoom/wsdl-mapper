require 'test_helper'

require 'wsdl_mapper/svc_generation/svc_generator'

module SvcDescParsingTests
  class OperationS8rGeneratorTest < GenerationTest
    include WsdlMapper::SvcGeneration
    include WsdlMapper::Dom

    NS = 'http://example.org/schema'
    SOAP_ENV = 'http://www.w3.org/2001/12/soap-envelope'

    def generate name
      @desc = TestHelper.parse_wsdl name
      generator = SvcGenerator.new context
      generator.generate @desc
    end

    focus
    def test_rpc_encoded_input_body_s8r
      generate 'price_service_rpc_encoded.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_s8r.rb', <<RUBY
        def build_body(x, body)
          x.complex(nil, ["#{SOAP_ENV}", "Body"], []) do |x|
            x.complex(nil, ["http://example.org/schema", "GetProductPrice"], []) do |x|
              x.get("::ProductIDType").build(x, body.product_idpart, ["http://example.org/schema", "ProductIDPart"])
              x.get("::VariantIDType").build(x, body.variant_idpart, ["http://example.org/schema", "VariantIDPart"])
            end
          end
        end
RUBY
    end

    focus
    def test_doc_encoded_input_body_s8r
      generate 'price_service_doc_encoded.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_s8r.rb', <<RUBY
        def build_body(x, body)
          x.complex(nil, ["#{SOAP_ENV}", "Body"], []) do |x|
            x.get("::ProductIDType").build(x, body.product_idpart, ["http://example.org/schema", "ProductIDPart"])
            x.get("::VariantIDType").build(x, body.variant_idpart, ["http://example.org/schema", "VariantIDPart"])
          end
        end
RUBY
    end

    focus
    def test_doc_literal_input_body_elements_s8r
      generate 'price_service_doc_literal.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_s8r.rb', <<RUBY
        def build_body(x, body)
          x.complex(nil, ["#{SOAP_ENV}", "Body"], []) do |x|
            x.get("::ProductIDInlineType").build(x, body.product_idpart, ["http://example.org/schema", "ProductID"])
            x.get("::VariantIDType").build(x, body.variant_idpart, ["http://example.org/schema", "VariantID"])
          end
        end
RUBY
    end

    focus
    def test_literal_input_header_element_s8r
      generate 'price_service_doc_literal.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_s8r.rb', <<RUBY
        def build_header(x, header)
          x.complex(nil, ["#{SOAP_ENV}", "Header"], []) do |x|
            x.complex(nil, ["http://example.org/schema", "UserAndPassword"], []) do |x|
              x.get("::CredentialsInlineType").build(x, header.credentials_user_and_password, ["http://example.org/schema", "Credentials"])
            end
          end
        end
RUBY
    end

    focus
    def test_literal_input_header_type_s8r
      generate 'price_service_doc_literal_type.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_s8r.rb', <<RUBY
        def build_header(x, header)
          x.get("::CredentialsType").build(x, header.credentials_user_and_password, ["#{SOAP_ENV}", "Header"])
        end
RUBY
    end

    focus
    def test_encoded_input_header_s8r
      generate 'price_service_rpc_encoded.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_s8r.rb', <<RUBY
        def build_header(x, header)
          x.complex(nil, ["#{SOAP_ENV}", "Header"], []) do |x|
            x.get("::CredentialsType").build(x, header.credentials_user_and_password, ["http://example.org/schema", "UserAndPassword"])
          end
        end
RUBY
    end

    focus
    def test_doc_literal_input_body_type_s8r
      generate 'price_service_doc_literal_type.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_s8r.rb', <<RUBY
        def build_body(x, body)
          x.get("::ProductIDType").build(x, body.product_idpart, ["#{SOAP_ENV}", "Body"])
        end
RUBY
    end

    focus
    def test_rpc_literal_input_body_s8r
      generate 'price_service_rpc_literal.wsdl'

      assert_file_contains 'price_service/product_prices/get_product_price/input_s8r.rb', <<RUBY
        def build_body(x, body)
          x.complex(nil, ["#{SOAP_ENV}", "Body"], []) do |x|
            x.complex(nil, ["http://example.org/schema", "GetProductPrice"], []) do |x|
              x.complex(nil, ["http://example.org/schema", "ProductIDPart"], []) do |x|
                x.get("::ProductIDInlineType").build(x, body.product_idpart, ["http://example.org/schema", "ProductID"])
              end
              x.get("::VariantIDType").build(x, body.variant_idpart, ["http://example.org/schema", "VariantIDPart"])
            end
          end
        end
RUBY
    end
  end
end
