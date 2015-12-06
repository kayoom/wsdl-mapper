require 'wsdl_mapper/runtime/simpler_inspect'

module WsdlMapper
  module Runtime
    class Port
      include SimplerInspect

      attr_reader :_soap_address, :_operations

      def initialize(api, service)
        @_api = api
        @_service = service
        @_soap_address = nil
        @_operations = []
      end
    end
  end
end
