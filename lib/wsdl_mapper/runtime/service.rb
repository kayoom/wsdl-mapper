require 'wsdl_mapper/runtime/simpler_inspect'

module WsdlMapper
  module Runtime
    class Service
      include SimplerInspect

      attr_reader :_ports

      def initialize(api)
        @_api = api
        @_ports = []
      end

      def _load_requires
        @_ports.each &:_load_requires
      end
    end
  end
end
