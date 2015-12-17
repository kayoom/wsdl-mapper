require 'faraday'

require 'wsdl_mapper/runtime/backend_base'

require 'wsdl_mapper/runtime/middlewares/simple_message_factory'
require 'wsdl_mapper/runtime/middlewares/simple_request_factory'
require 'wsdl_mapper/runtime/middlewares/simple_dispatcher'
require 'wsdl_mapper/runtime/middlewares/simple_response_factory'

module WsdlMapper
  module Runtime
    # ## Middleware Stack
    # ### Default Configuration
    # The default stack is composed of the following middlewares:
    # ![Diagram](/docs/file/doc/diag/simple_http_backend.png)
    # 1. `message.factory`: {WsdlMapper::Runtime::Middlewares::SimpleMessageFactory}
    # 2. `request.factory`: {WsdlMapper::Runtime::Middlewares::SimpleRequestFactory}
    # 3. `dispatcher`: {WsdlMapper::Runtime::Middlewares::SimpleDispatcher}
    # 4. `response.factory`: {WsdlMapper::Runtime::Middlewares::SimpleResponseFactory}
    #
    # ## Customization
    class SimpleHttpBackend < BackendBase
      include WsdlMapper::Runtime::Middlewares

      def initialize(connection: Faraday.new)
        super()
        stack.add 'message.factory', SimpleMessageFactory.new
        stack.add 'request.factory', SimpleRequestFactory.new
        stack.add 'dispatcher', SimpleDispatcher.new(connection)
        stack.add 'response.factory', SimpleResponseFactory.new
      end
    end
  end
end
