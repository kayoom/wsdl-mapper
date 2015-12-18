require 'wsdl_mapper/runtime/backend_base'
require 'concurrent'
require 'faraday'

require 'wsdl_mapper/runtime/middlewares/async_message_factory'
require 'wsdl_mapper/runtime/middlewares/async_request_factory'
require 'wsdl_mapper/runtime/middlewares/async_dispatcher'
require 'wsdl_mapper/runtime/middlewares/async_response_factory'

module WsdlMapper
  module Runtime
    # ## Middleware Stack
    # ### Default Configuration
    # The default stack is composed of the following middlewares:
    # ![Diagram](/docs/file/doc/diag/async_backend.png)
    # 1. `message.factory`: {WsdlMapper::Runtime::Middlewares::AsyncMessageFactory}
    # 2. `request.factory`: {WsdlMapper::Runtime::Middlewares::AsyncRequestFactory}
    # 3. `dispatcher`: {WsdlMapper::Runtime::Middlewares::AsyncDispatcher}
    # 4. `response.factory`: {WsdlMapper::Runtime::Middlewares::AsyncResponseFactory}
    class AsyncHttpBackend < BackendBase
      include WsdlMapper::Runtime::Middlewares

      def initialize(connection: Faraday.new, executor: nil)
        super()
        @executor = executor

        stack.add 'message.factory', AsyncMessageFactory.new
        stack.add 'request.factory', AsyncRequestFactory.new
        stack.add 'dispatcher', AsyncDispatcher.new(connection)
        stack.add 'response.factory', AsyncResponseFactory.new
      end

      # Takes an `operation` and arguments, wraps them in a new {Concurrent::Promise},
      # passes them to the {#stack} and returns the response promise.
      # @param [WsdlMapper::Runtime::Operation] operation
      # @param [Array] args
      # @return [Concurrent::Promise] The unscheduled response promise.
      def dispatch(operation, *args)
        promise = Concurrent::Promise.new(executor: @executor) { args }
        dispatch_async operation, promise
      end

      # Passes a promise to the stack and returns the response promise.
      # @param [WsdlMapper::Runtime::Operation] operation
      # @param [Concurrent::Promise] promise
      # @return [Concurrent::Promise] The unscheduled response promise.
      def dispatch_async(operation, promise)
        stack.execute([operation, promise]).last
      end
    end
  end
end
