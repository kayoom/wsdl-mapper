require 'wsdl_mapper/runtime/middlewares/simple_response_factory'

module WsdlMapper
  module Runtime
    module Middlewares
      class AsyncResponseFactory < SimpleResponseFactory
        def call(operation, http_response_promise)
          response_promise = http_response_promise.then do |http_response|
            super(operation, http_response).last
          end

          [operation, response_promise]
        end
      end
    end
  end
end
