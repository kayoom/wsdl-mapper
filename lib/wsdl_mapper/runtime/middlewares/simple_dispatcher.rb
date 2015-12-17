require 'faraday'

require 'wsdl_mapper/runtime/errors'

module WsdlMapper
  module Runtime
    module Middlewares
      class SimpleDispatcher
        include WsdlMapper::Runtime::Errors

        attr_reader :cnx

        def initialize(connection)
          @cnx = connection
        end

        # Dispatches the request via the configured {#cnx} and returns the HTTP response.
        # @param [WsdlMapper::Runtime::Operation] operation
        # @param [WsdlMapper::Runtime::Request] request
        # @return [Array<WsdlMapper::Runtime::Operation, Faraday::Response>]
        # @raise [WsdlMapper::Runtime::Errors::TransportError] if a network error occured
        def call(operation, request)
          begin
            http_response = cnx.post do |c|
              c.url request.url
              c.body = request.xml

              request.http_headers.each do |key, val|
                c[key] = val
              end
            end

            [operation, http_response]
          rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Faraday::Error => e
            raise TransportError.new(e.message, e)
          end
        end
      end
    end
  end
end
