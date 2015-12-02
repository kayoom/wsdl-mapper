require 'test_helper'

require 'wsdl_mapper/dom/name'
require 'wsdl_mapper/deserializers/deserializer'
require 'wsdl_mapper/core_ext/time_duration'

module DeserializersTests
  class DeserializerTest < ::WsdlMapperTesting::Test
    include WsdlMapper::CoreExt
    include WsdlMapper::Dom
    include WsdlMapper::Deserializers

    BUILTIN = lambda do |name|
      [WsdlMapper::Dom::BuiltinType::NAMESPACE, name]
    end

    NS = 'http://example.org/schema'

    SimpleExampleRpcEncoded = <<RUBY
  require 'wsdl_mapper/svc_desc/envelope'
  require "wsdl_mapper/deserializers/type_directory"
  require "wsdl_mapper/deserializers/element_directory"
  class PriceInlineType
    attr_accessor :content, :currency

    def initialize content, currency: nil
      @content = content
      @currency = currency
    end
  end
  class OutputBody
    attr_accessor :price

    def initialize price: nil
      @price = price
    end
  end
  class OutputHeader
  end
  TypeDirectory = ::WsdlMapper::Deserializers::TypeDirectory.new
  PriceInlineTypeDeserializer = TypeDirectory.register_type(['http://example.org/schema', 'PriceInlineType'], PriceInlineType, simple: ['http://www.w3.org/2001/XMLSchema', 'double']) do
    register_attr(:currency, ['http://example.org/schema', 'Currency'], ['http://www.w3.org/2001/XMLSchema', 'string'])
  end
  OutputBodyDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Body'], OutputBody) do
    register_prop(:price, ['http://example.org/schema', 'Price'], ['http://example.org/schema', 'PriceInlineType'])
    register_wrapper(['http://example.org/schema', 'GetProductPriceResponse'])
  end
  OutputHeaderDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Header'], OutputHeader) do
  end
  EnvelopeDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ::WsdlMapper::SvcDesc::Envelope) do
    register_prop(:header, ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'])
    register_prop(:body, ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'])
  end
  ElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(TypeDirectory) do
    register_element ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], 'wsdl_mapper/svc_desc/envelope', ::WsdlMapper::SvcDesc::Envelope

    def require(path); end
  end
RUBY

    def test_simple_example_rpc_encoded
      xml = <<XML
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sch="http://example.org/schema">
  <soapenv:Header/>
  <soapenv:Body>
    <sch:GetProductPriceResponse>
      <sch:Price Currency="EUR">123.45</sch:Price>
    </sch:GetProductPriceResponse>
  </soapenv:Body>
</soapenv:Envelope>
XML
      test_module = create_test_module SimpleExampleRpcEncoded

      deserializer = LazyLoadingDeserializer.new test_module.const_get('ElementDirectory')
      obj = deserializer.from_xml xml

      assert_kind_of WsdlMapper::SvcDesc::Envelope, obj
      assert_kind_of test_module.const_get(:OutputBody), obj.body
      assert_kind_of test_module.const_get(:PriceInlineType), obj.body.price

      assert_equal 123.45, obj.body.price.content
      assert_equal 'EUR', obj.body.price.currency
    end

    SimpleExampleRpcLiteral = <<RUBY
  require 'wsdl_mapper/svc_desc/envelope'
  require "wsdl_mapper/deserializers/type_directory"
  require "wsdl_mapper/deserializers/element_directory"
  class PriceInlineType
    attr_accessor :content, :currency

    def initialize content, currency: nil
      @content = content
      @currency = currency
    end
  end
  class OutputBody
    attr_accessor :price

    def initialize price: nil
      @price = price
    end
  end
  class OutputHeader
  end
  TypeDirectory = ::WsdlMapper::Deserializers::TypeDirectory.new
  PriceInlineTypeDeserializer = TypeDirectory.register_type(['http://example.org/schema', 'PriceInlineType'], PriceInlineType, simple: ['http://www.w3.org/2001/XMLSchema', 'double']) do
    register_attr(:currency, ['http://example.org/schema', 'Currency'], ['http://www.w3.org/2001/XMLSchema', 'string'])
  end
  OutputBodyDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Body'], OutputBody) do
    register_prop(:price, ['http://example.org/schema', 'Price'], ['http://example.org/schema', 'PriceInlineType'])
    register_wrapper(['http://example.org/schema', 'GetProductPriceResponse'])
  end
  OutputHeaderDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Header'], OutputHeader) do
  end
  EnvelopeDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ::WsdlMapper::SvcDesc::Envelope) do
    register_prop(:header, ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'])
    register_prop(:body, ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'])
  end
  ElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(TypeDirectory) do
    register_element ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], 'wsdl_mapper/svc_desc/envelope', ::WsdlMapper::SvcDesc::Envelope

    def require(path); end
  end
RUBY

    def test_simple_example_rpc_literal
      xml = <<XML
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sch="http://example.org/schema">
  <soapenv:Header/>
  <soapenv:Body>
    <sch:GetProductPriceResponse>
      <sch:Price Currency="EUR">123.45</sch:Price>
    </sch:GetProductPriceResponse>
  </soapenv:Body>
</soapenv:Envelope>
XML
      test_module = create_test_module SimpleExampleRpcLiteral

      deserializer = LazyLoadingDeserializer.new test_module.const_get('ElementDirectory')
      obj = deserializer.from_xml xml

      assert_kind_of WsdlMapper::SvcDesc::Envelope, obj
      assert_kind_of test_module.const_get(:OutputBody), obj.body
      assert_kind_of test_module.const_get(:PriceInlineType), obj.body.price

      assert_equal 123.45, obj.body.price.content
      assert_equal 'EUR', obj.body.price.currency
    end

    SimpleExampleDocLiteralType = <<RUBY
  require 'wsdl_mapper/svc_desc/envelope'
  require "wsdl_mapper/deserializers/type_directory"
  require "wsdl_mapper/deserializers/element_directory"
  class PriceInlineType
    attr_accessor :content, :currency

    def initialize content, currency: nil
      @content = content
      @currency = currency
    end
  end
  class OutputBody
    attr_accessor :price

    def initialize price: nil
      @price = price
    end
  end
  class OutputHeader
  end
  TypeDirectory = ::WsdlMapper::Deserializers::TypeDirectory.new
  PriceInlineTypeDeserializer = TypeDirectory.register_type(['http://example.org/schema', 'PriceInlineType'], PriceInlineType, simple: ['http://www.w3.org/2001/XMLSchema', 'double']) do
    register_attr(:currency, ['http://example.org/schema', 'Currency'], ['http://www.w3.org/2001/XMLSchema', 'string'])
  end
  OutputBodyDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Body'], OutputBody) do
    register_delegate(:price, ['http://example.org/schema', 'PriceInlineType'])
  end
  OutputHeaderDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Header'], OutputHeader) do
  end
  EnvelopeDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ::WsdlMapper::SvcDesc::Envelope) do
    register_prop(:header, ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'])
    register_prop(:body, ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'])
  end
  ElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(TypeDirectory) do
    register_element ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], 'wsdl_mapper/svc_desc/envelope', ::WsdlMapper::SvcDesc::Envelope

    def require(path); end
  end
RUBY

    def test_simple_example_doc_literal_with_type
      xml = <<XML
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sch="http://example.org/schema">
  <soapenv:Header/>
  <soapenv:Body sch:Currency="EUR">
      123.45
  </soapenv:Body>
</soapenv:Envelope>
XML

      test_module = create_test_module SimpleExampleDocLiteralType

      deserializer = LazyLoadingDeserializer.new test_module.const_get('ElementDirectory')
      obj = deserializer.from_xml xml

      assert_kind_of WsdlMapper::SvcDesc::Envelope, obj
      assert_kind_of test_module.const_get(:OutputBody), obj.body
      assert_kind_of test_module.const_get(:PriceInlineType), obj.body.price

      assert_equal 123.45, obj.body.price.content
      assert_equal 'EUR', obj.body.price.currency
    end

    SimpleExampleDocLiteralInline = <<RUBY
  require 'wsdl_mapper/svc_desc/envelope'
  require "wsdl_mapper/deserializers/type_directory"
  require "wsdl_mapper/deserializers/element_directory"
  class PriceInlineType
    attr_accessor :content, :currency

    def initialize content, currency: nil
      @content = content
      @currency = currency
    end
  end
  class OutputBody
    attr_accessor :price

    def initialize price: nil
      @price = price
    end
  end
  class OutputHeader
  end
  TypeDirectory = ::WsdlMapper::Deserializers::TypeDirectory.new
  PriceInlineTypeDeserializer = TypeDirectory.register_type(['http://example.org/schema', 'PriceInlineType'], PriceInlineType, simple: ['http://www.w3.org/2001/XMLSchema', 'double']) do
    register_attr(:currency, ['http://example.org/schema', 'Currency'], ['http://www.w3.org/2001/XMLSchema', 'string'])
  end
  OutputBodyDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Body'], OutputBody) do
    register_prop(:price, ['http://example.org/schema', 'Price'], ['http://example.org/schema', 'PriceInlineType'])
  end
  OutputHeaderDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Header'], OutputHeader) do
  end
  EnvelopeDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ::WsdlMapper::SvcDesc::Envelope) do
    register_prop(:header, ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'])
    register_prop(:body, ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'])
  end
  ElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(TypeDirectory) do
    register_element ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], 'wsdl_mapper/svc_desc/envelope', ::WsdlMapper::SvcDesc::Envelope

    def require(path); end
  end
RUBY

    def test_simple_example_doc_literal_inline
      xml = <<XML
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sch="http://example.org/schema">
  <soapenv:Header/>
  <soapenv:Body>
    <sch:Price Currency="EUR">
      123.45
    </sch:Price>
  </soapenv:Body>
</soapenv:Envelope>
XML

      test_module = create_test_module SimpleExampleDocLiteralInline

      deserializer = LazyLoadingDeserializer.new test_module.const_get('ElementDirectory')
      obj = deserializer.from_xml xml

      assert_kind_of WsdlMapper::SvcDesc::Envelope, obj
      assert_kind_of test_module.const_get(:OutputBody), obj.body
      assert_kind_of test_module.const_get(:PriceInlineType), obj.body.price

      assert_equal 123.45, obj.body.price.content
      assert_equal 'EUR', obj.body.price.currency
    end

#     SimpleExampleDocEncoded = <<RUBY
#   require 'wsdl_mapper/svc_desc/envelope'
#   require "wsdl_mapper/deserializers/type_directory"
#   require "wsdl_mapper/deserializers/element_directory"
#   class PriceInlineType
#     attr_accessor :content, :currency
#
#     def initialize content, currency: nil
#       @content = content
#       @currency = currency
#     end
#   end
#   class OutputBody
#     attr_accessor :price
#
#     def initialize price: nil
#       @price = price
#     end
#   end
#   class OutputHeader
#   end
#   TypeDirectory = ::WsdlMapper::Deserializers::TypeDirectory.new
#   PriceInlineTypeDeserializer = TypeDirectory.register_type(['http://example.org/schema', 'PriceInlineType'], PriceInlineType, simple: ['http://www.w3.org/2001/XMLSchema', 'double']) do
#     register_attr(:currency, ['http://example.org/schema', 'Currency'], ['http://www.w3.org/2001/XMLSchema', 'string'])
#   end
#   OutputBodyDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Body'], OutputBody) do
#     register_prop(:price, ['http://example.org/schema', 'Price'], ['http://example.org/schema', 'PriceInlineType'])
#   end
#   OutputHeaderDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Header'], OutputHeader) do
#   end
#   EnvelopeDeserializer = TypeDirectory.register_type(['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ::WsdlMapper::SvcDesc::Envelope) do
#     register_prop(:header, ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Header'])
#     register_prop(:body, ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Body'])
#   end
#   ElementDirectory = ::WsdlMapper::Deserializers::ElementDirectory.new(TypeDirectory) do
#     register_element ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], ['http://schemas.xmlsoap.org/soap/envelope/', 'Envelope'], 'wsdl_mapper/svc_desc/envelope', ::WsdlMapper::SvcDesc::Envelope
#
#     def require(path); end
#   end
# RUBY
#
#     focus
#     def test_simple_example_doc_encoded
#       xml = <<XML
# <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sch="http://example.org/schema">
#   <soapenv:Header/>
#   <soapenv:Body>
#     <sch:Price Currency="EUR">
#       123.45
#     </sch:Price>
#   </soapenv:Body>
# </soapenv:Envelope>
# XML
#
#       test_module = create_test_module SimpleExampleDocLiteral
#
#       deserializer = LazyLoadingDeserializer.new test_module.const_get('ElementDirectory')
#       obj = deserializer.from_xml xml
#
#       assert_kind_of WsdlMapper::SvcDesc::Envelope, obj
#       assert_kind_of test_module.const_get(:OutputBody), obj.body
#       assert_kind_of test_module.const_get(:PriceInlineType), obj.body.price
#
#       assert_equal 123.45, obj.body.price.content
#       assert_equal 'EUR', obj.body.price.currency
#     end
  end
end
