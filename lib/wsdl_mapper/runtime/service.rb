require 'wsdl_mapper/runtime/simpler_inspect'

module WsdlMapper
  module Runtime
    class Service
      include SimplerInspect

      def initialize(api)
        @_api = api
        @_ports = []
      end
    end
  end
end
