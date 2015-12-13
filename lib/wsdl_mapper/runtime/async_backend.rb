require 'wsdl_mapper/runtime/backend_base'
require 'concurrent'
require 'faraday'

module WsdlMapper
  module Runtime
    class AsyncBackend < BackendBase
      class AsyncMessageFactory < SimpleMessageFactory
        def call(operation, promise)
          message_promise = promise.then do |(body, args)|
            super(operation, body, args).last
          end

          [operation, message_promise]
        end
      end

      class AsyncRequestFactory < SimpleRequestFactory
        def call(operation, message_promise)
          request_promise = message_promise.then do |message|
            super(operation, message).last
          end

          [operation, request_promise]
        end
      end

      class AsyncDispatcher
        def initialize(adapter: :net_http)
          @adapter = adapter
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

        def cnx
          @cnx ||= Faraday.new do |c|
            c.adapter @adapter
          end
        end
      end

      class AsyncResponseFactory < SimpleResponseFactory
        def call(operation, http_response_promise)
          response_promise = http_response_promise.then do |http_response|
            super(operation, nil, http_response, nil)[-2]
          end

          [operation, response_promise]
        end
      end

      def initialize(adapter: :net_http)
        super()
        stack.add 'async.input', -> (operation, body, args) { promise = Concurrent::Promise.new { [body, args] }; [operation, promise] }
        stack.add 'message.factory', AsyncMessageFactory.new
        stack.add 'request.factory', AsyncRequestFactory.new
        stack.add 'dispatcher', AsyncDispatcher.new(adapter: adapter)
        stack.add 'response.factory', AsyncResponseFactory.new
        stack.add 'response.processor', -> (operation, response_promise) { response_promise }
      end
    end
  end
end
