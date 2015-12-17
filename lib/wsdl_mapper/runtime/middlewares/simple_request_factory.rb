require 'wsdl_mapper/runtime/request'

module WsdlMapper
  module Runtime
    module Middlewares
      class SimpleRequestFactory
        # Serializes the `message`, sets the service URL and adds SOAPAction and Content-Type headers. For serialization
        # it relies on {WsdlMapper::Runtime::Operation#input_s8r} to return the proper input serializer for this operation.
        # @param [WsdlMapper::Runtime::Operation] operation
        # @param [WsdlMapper::Runtime::Message] message
        # @return [Array<WsdlMapper::Runtime::Operation, WsdlMapper::Runtime::Request>]
        def call(operation, message)
          request = WsdlMapper::Runtime::Request.new message
          serialize_envelope request, operation, message
          set_url request, operation, message
          add_http_headers request, operation, message

          [operation, request]
        end

        protected
        def add_http_headers(request, operation, message)
          request.add_http_header 'SOAPAction', message.action
          request.add_http_header 'Content-Type', 'text/xml'
        end

        def set_url(request, operation, message)
          request.url = URI(message.address)
        end

        def serialize_envelope(request, operation, message)
          request.xml = operation.input_s8r.to_xml(message.envelope)
        end
      end
    end
  end
end
