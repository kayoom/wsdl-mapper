require 'wsdl_mapper/runtime/middlewares/simple_response_logger'

module WsdlMapper
  module Runtime
    module Middlewares
      class AsyncResponseLogger < SimpleResponseLogger
        def call(operation, response_promise)
          promise = response_promise.then do |response|
            super(operation, response).last
          end

          [operation, promise]
        end
      end
    end
  end
end
