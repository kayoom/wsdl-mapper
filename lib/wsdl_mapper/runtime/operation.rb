require 'wsdl_mapper/runtime/soap_message'

module WsdlMapper
  module Runtime
    class Operation
      def initialize(api, service, port)
        @api = api
        @service = service
        @port = port
      end

      def input_scaffold
        message = SoapMessage.new
      end

    end
  end
end
