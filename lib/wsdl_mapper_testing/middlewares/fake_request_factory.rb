require 'wsdl_mapper/runtime/middlewares/simple_request_factory'

module WsdlMapperTesting
  module Middlewares
    class FakeRequestFactory < WsdlMapper::Runtime::Middlewares::SimpleRequestFactory
      def initialize
        @xml = {}
      end

      def fake_s8r(body, xml)
        @xml[body] = xml
      end

      protected
      def serialize_envelope(request, operation, message)
        request.xml = @xml[message.envelope.body]
      end
    end
  end
end
