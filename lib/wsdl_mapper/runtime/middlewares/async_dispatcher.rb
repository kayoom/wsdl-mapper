require 'faraday'

module WsdlMapper
  module Runtime
    module Middlewares
      class AsyncDispatcher
        attr_reader :cnx

        def initialize(connection = Faraday.new)
          @cnx = connection
        end

        def call(operation, request_promise)
          http_response_promise = request_promise.then do |request|
            cnx.post do |c|
              c.url request.url
              c.body = request.xml

              request.http_headers.each do |key, val|
                c[key] = val
              end
            end
          end

          [operation, http_response_promise]
        end
      end
    end
  end
end
