require 'wsdl_mapper/runtime/backend_base'
require 'concurrent'
require 'faraday'

module WsdlMapper
  module Runtime
    class AsyncBackend < BackendBase
      def initialize(adapter: :net_http, executor: nil)
        super()
        @executor = executor

        stack.add 'message.factory', AsyncMessageFactory.new
        stack.add 'request.factory', AsyncRequestFactory.new
        stack.add 'dispatcher', AsyncDispatcher.new(adapter: adapter)
        stack.add 'response.factory', AsyncResponseFactory.new
        stack.add 'response.processor', -> (operation, response_promise) { response_promise }
      end

      def dispatch(operation, *args)
        promise = Concurrent::Promise.new(executor: @executor) { args }
        stack.execute [operation, promise]
      end
    end
  end
end
