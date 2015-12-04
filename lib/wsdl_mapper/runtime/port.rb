require 'wsdl_mapper/runtime/simpler_inspect'

module WsdlMapper
  module Runtime
    class Port
      include SimplerInspect

      def initialize api, service
        @_api = api
        @_service = service
        @_operations = []
      end
    end
  end
end
