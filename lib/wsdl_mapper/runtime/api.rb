require 'wsdl_mapper/runtime/simpler_inspect'
require 'wsdl_mapper/runtime/proxy'

module WsdlMapper
  module Runtime
    class Api
      include SimplerInspect

      attr_reader :_services

      # @!attribute _services
      #   @return [Array<WsdlMapper::Runtime::Service>] All services contained in this API

      # @param [WsdlMapper::Runtime::SimpleHttpBackend] backend The backend to use
      def initialize(backend)
        @_backend = backend
        @_services = []
      end

      # Executes a request using the configured backend.
      # @param [WsdlMapper::Runtime::Operation] operation Operation to call
      # @param [Array] args Request input
      # @return [Object] Response
      def _call(operation, *args)
        @_backend.dispatch operation, *args
      end

      # Executes a request async using the configured backend.
      # @param [WsdlMapper::Runtime::Operation] operation Operation to call
      # @param [Concurrent::Promise] args_promise Promise for request input
      # @return [Concurrent::Promise] Promise for the response
      def _call_async(operation, args_promise)
        @_backend.dispatch_async operation, args_promise
      end

      # Force preloading of requires for all contained services
      def _load_requires
        @_services.each(&:_load_requires)
      end
    end
  end
end
