require 'faraday'
require 'wsdl_mapper/runtime/middlewares/simple_dispatcher'

module WsdlMapper
  module Runtime
    module Middlewares
      class AsyncDispatcher < SimpleDispatcher
        # @api internal
        # @param [WsdlMapper::Runtime::Operation] operation Operation to perform / call to make
        # @param [Concurrent::Promise] request_promise A promise for the request to perform
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
