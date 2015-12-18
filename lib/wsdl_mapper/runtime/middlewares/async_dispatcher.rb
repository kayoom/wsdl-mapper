require 'faraday'
require 'wsdl_mapper/runtime/middlewares/simple_dispatcher'

module WsdlMapper
  module Runtime
    module Middlewares
      class AsyncDispatcher < SimpleDispatcher
        attr_reader :cnx

        def initialize(connection = Faraday.new)
          @cnx = connection
        end

        def call(operation, request_promise)
          http_response_promise = request_promise.then do |request|
            super(operation, request).last
          end

          [operation, http_response_promise]
        end
      end
    end
  end
end
