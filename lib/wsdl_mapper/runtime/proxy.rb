module WsdlMapper
  module Runtime
    class Proxy
      # @param [WsdlMapper::Runtime::Api] api
      # @param [WsdlMapper::Runtime::Port] port
      def initialize(api, port)
        @_api = api
        @_port = port
      end
    end
  end
end
