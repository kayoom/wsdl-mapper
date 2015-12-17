require 'uri'
require 'wsdl_mapper/runtime/middleware_stack'

module WsdlMapper
  module Runtime
    class BackendBase
      attr_reader :stack

      # @!attribute stack
      #   @return [WsdlMapper::Runtime::MiddlewareStack]

      def initialize
        @stack = MiddlewareStack.new
      end

      def dispatch(operation, *input)
        stack.execute([operation, *input]).last
      end
    end
  end
end
