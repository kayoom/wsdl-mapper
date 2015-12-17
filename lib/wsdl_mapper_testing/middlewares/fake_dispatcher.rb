module WsdlMapperTesting
  module Middlewares
    class FakeDispatcher
      def initialize
        @requests = {}
      end

      def fake_request(request, http_response)
        @requests[request] = http_response
      end

      def call(operation, request)
        [operation, request, @requests[request]]
      end
    end
  end
end
