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

        def call(operation, request)
          begin
            http_response = cnx.post do |c|
              c.url request.url
              c.body = request.xml

              request.http_headers.each do |key, val|
                c[key] = val
              end
            end

            [operation, request, http_response]
          rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Faraday::Error => e
            raise TransportError.new(e.message, e)
          end
        end
      end
    end
  end
end
