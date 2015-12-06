require 'wsdl_mapper/runtime/simpler_inspect'
require 'wsdl_mapper/runtime/proxy'

module WsdlMapper
  module Runtime
    class Api
      include SimplerInspect

      def initialize(backend)
        @_backend = backend
        @_services = []
      end

      def _call(operation, body, *args)
        @_backend.dispatch operation, body, *args
      end
    end
  end
end
