require 'wsdl_mapper/runtime/middlewares/simple_request_factory'

module WsdlMapper
  module Runtime
    module Middlewares
      class AsyncRequestFactory < SimpleRequestFactory
        def call(operation, message_promise)
          request_promise = message_promise.then do |message|
            super(operation, message).last
          end

          [operation, request_promise]
        end
      end
    end
  end
end
