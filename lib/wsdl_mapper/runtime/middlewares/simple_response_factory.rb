require 'wsdl_mapper/runtime/response'

module WsdlMapper
  module Runtime
    module Middlewares
      class SimpleResponseFactory
        def call(operation, request, http_response)
          response = Response.new http_response.status, http_response.body
          deserialize_envelope operation, response

          [operation, request, response]
        end

        protected
        def deserialize_envelope(operation, response)
          response.envelope = operation.output_d10r.from_xml response.body
        end
      end
    end
  end
end
