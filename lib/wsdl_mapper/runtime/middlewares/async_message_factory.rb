require 'wsdl_mapper/runtime/middlewares/simple_message_factory'

module WsdlMapper
  module Runtime
    module Middlewares
      class AsyncMessageFactory < SimpleMessageFactory
        def call(operation, promise)
          message_promise = promise.then do |(body, args)|
            super(operation, body, args).last
          end

          [operation, message_promise]
        end
      end
    end
  end
end
