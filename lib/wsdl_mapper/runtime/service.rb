require 'wsdl_mapper/runtime/simpler_inspect'

module WsdlMapper
  module Runtime
    class Service
      include SimplerInspect

      attr_reader :_ports

      # @!attribute _ports
      #   @return [Array<WsdlMapper::Runtime::Port>] All ports contained in this service

      # @param [WsdlMapper::Runtime::Api] api
      def initialize(api)
        @_api = api
        @_ports = []
      end

      # Force preloading of requires for all contained ports
      def _load_requires
        @_ports.each(&:_load_requires)
      end
    end
  end
end
