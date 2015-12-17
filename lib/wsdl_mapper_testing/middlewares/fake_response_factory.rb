require 'wsdl_mapper/runtime/middlewares/simple_response_factory'

module WsdlMapperTesting
  module Middlewares
    class FakeResponseFactory < WsdlMapper::Runtime::Middlewares::SimpleResponseFactory
      def initialize
        @xml = {}
      end

      def fake_d10r(xml, body)
        @xml[xml] = body
      end

      protected
      def deserialize_envelope(operation, response)
        response.envelope = @xml[response.body]
      end
    end
  end
end
