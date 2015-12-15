module WsdlMapper
  module Runtime
    module Middlewares
      class SimpleMessageFactory
        def call(operation, body, args)
          message = operation.new_input body: body

          [operation, message]
        end
      end
    end
  end
end
