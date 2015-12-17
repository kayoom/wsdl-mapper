require 'wsdl_mapper/svc_desc/envelope'
require 'wsdl_mapper/runtime/message'

module WsdlMapperTesting
  module Middlewares
    class FakeMessageFactory
      attr_accessor :url, :action

      def initialize(url = nil, action = nil, header =nil)
        @url = url
        @action = action
        @header = header
      end

      def call(operation, body, args)
        envelope = WsdlMapper::SvcDesc::Envelope.new header: @header, body: body
        message = WsdlMapper::Runtime::Message.new @url, @action, envelope

        [operation, message]
      end
    end
  end
end
