require 'faraday'

require 'wsdl_mapper/runtime/backend_base'

module WsdlMapper
  module Runtime
    class SimpleHttpBackend < BackendBase
      def initialize(connection: Faraday.new)
        stack.add 'message.factory', SimpleMessageFactory.new
        stack.add 'request.factory', SimpleRequestFactory.new
        stack.add 'dispatcher', SimpleDispatcher.new(connection)
        stack.add 'response.factory', SimpleResponseFactory.new
        stack.add 'response.processor', -> (operation, request, response) { response }
      end
    end
  end
end
