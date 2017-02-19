require 'wsdl_mapper/runtime/simpler_inspect'

module WsdlMapper
  module Runtime
    class Port
      include SimplerInspect

      attr_reader :_soap_address, :_operations

      # @!attribute _operations
      #   @return [Array<WsdlMapper::Runtime::Operation>] All operations contained in this port
      # @!attribute _soap_address
      #   @return [String] URL of the SOAP service

      # @param [WsdlMapper::Runtime::Api] api The API this port belongs to
      # @param [WsdlMapper::Runtime::Service] service The service this port belongs to
      def initialize(api, service)
        @_api = api
        @_service = service
        @_soap_address = nil
        @_operations = []
      end

      # Force preloading of requires for all contained operations
      def _load_requires
        @_operations.each(&:load_requires)
      end
    end
  end
end
