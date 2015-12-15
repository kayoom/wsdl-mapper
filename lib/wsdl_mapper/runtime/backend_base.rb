require 'uri'
require 'wsdl_mapper/runtime/middleware_stack'

module WsdlMapper
  module Runtime
    class BackendBase
      attr_reader :stack

      def initialize
        @stack = MiddlewareStack.new
      end

      def dispatch(operation, body, **options)
        stack.execute [operation, body, options]
      end
    end
  end
end
