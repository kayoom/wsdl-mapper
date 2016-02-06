require 'wsdl_mapper/runtime/middlewares/simple_request_logger'

module WsdlMapper
  module Runtime
    module Middlewares
      class AsyncRequestLogger < SimpleRequestLogger
        def call(operation, request_promise)
          promise = request_promise.then do |request|
            super(operation, request).last
          end

          [operation, promise]
        end
      end
    end
  end
end
