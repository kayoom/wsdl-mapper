module WsdlMapper
  module Runtime
    module Middlewares
      class SimpleMessageFactory
        # Creates a new {WsdlMapper::Runtime::Message} with the given input `body`. It relies on {WsdlMapper::Runtime::Operation#new_input} to create the message.
        # @param [WsdlMapper::Runtime::Operation] operation
        # @param [Hash] body Arguments for the operations input body constructor
        # @param [Array] args
        # @return [Array<WsdlMapper::Runtime::Operation, WsdlMapper::Runtime::Message>]
        def call(operation, body, *args)
          message = operation.new_input body: body

          [operation, message]
        end
      end
    end
  end
end
