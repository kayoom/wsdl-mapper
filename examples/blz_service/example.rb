require 'rubygems'
require 'bundler/setup'

$:.unshift './lib'

require 'wsdl_mapper/runtime/simple_http_backend'
require 'blz_service'
require 'blz_service/api'
require 'blz_service/blzservice/blzservice_soap11port_http_proxy'

# Initialize an HttpBackend
backend = WsdlMapper::Runtime::SimpleHttpBackend.new

# Instantiate API
api = BlzService::Api.new backend

# Instantiate a proxy for simple rpc-ing
client = BlzService::BLZService::BLZServiceSOAP11portHttpProxy.new api, api.blzservice.blzservice_soap11port_http

# Execute request
response = client.get_bank parameters: BlzService::Types::GetBankType.new(blz: '39550110')

details = response.envelope.body.parameters.details

puts "Bezeichnung:\t" + details.bezeichnung
puts "BIC:\t\t" + details.bic
puts "Ort:\t\t" + details.ort
puts "PLZ:\t\t" + details.plz
