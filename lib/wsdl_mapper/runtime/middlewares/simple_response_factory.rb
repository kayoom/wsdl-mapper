require 'wsdl_mapper/runtime/response'

module WsdlMapper
  module Runtime
    module Middlewares
      class SimpleResponseFactory
        # Deserializes the `http_response` body. It relies on {WsdlMapper::Runtime::Operation#output_d10r} to return the proper output
        # deserializer for this operation.
        # @param [WsdlMapper::Runtime::Operation] operation
        # @param [Faraday::Response] http_response
        # @return [Array<WsdlMapper::Runtime::Operation, WsdlMapper::Runtime::Response>]
        def call(operation, http_response)
          response = WsdlMapper::Runtime::Response.new http_response.status, http_response.body, http_response.headers
          deserialize_envelope operation, response

          [operation, response]
        end

        protected
        def deserialize_envelope(operation, response)
          response.envelope = operation.output_d10r.from_xml response.body
        end
      end
    end
  end
end
