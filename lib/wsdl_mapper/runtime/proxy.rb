module WsdlMapper
  module Runtime
    class Proxy
      def initialize(api, port)
        @_api = api
        @_port = port
      end
    end
  end
end
