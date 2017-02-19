require 'rubygems'
require 'bundler/setup'

$:.unshift './lib'

require 'wsdl_mapper/runtime/simple_http_backend'
require 'calculator'
require 'calculator/api'
require 'calculator/calculator/calculator_soap_proxy'

# Initialize an HttpBackend
backend = WsdlMapper::Runtime::SimpleHttpBackend.new

# Instantiate API
api = Calculator::Api.new backend

# Instantiate a proxy for simple rpc-ing
client = Calculator::Calculator::CalculatorSoapProxy.new(api, api.calculator.calculator_soap)

# Execute request
response = client.multiply parameters: Calculator::Types::MultiplyInlineType.new(int_a: 334, int_b: 432)

result = response.envelope.body.parameters.multiply_result

puts "334 * 432 = #{result}"
