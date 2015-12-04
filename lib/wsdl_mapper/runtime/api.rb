require 'wsdl_mapper/runtime/simpler_inspect'

module WsdlMapper
  module Runtime
    class Api
      include SimplerInspect

      def initialize(options = {})
        @_options = options
        @_services = []
      end
    end
  end
end
