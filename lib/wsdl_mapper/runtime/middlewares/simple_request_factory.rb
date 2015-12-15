require 'wsdl_mapper/runtime/request'

module WsdlMapper
  module Runtime
    module Middlewares
      class SimpleRequestFactory
        def call(operation, message)
          request = Request.new message
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
