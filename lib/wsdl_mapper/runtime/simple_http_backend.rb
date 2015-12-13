require 'wsdl_mapper/runtime/backend_base'
require 'faraday'
require 'logger'

module WsdlMapper
  module Runtime
    class SimpleHttpBackend < BackendBase
      include WsdlMapper::Runtime::Errors

      class SimpleDispatcher
        def initialize(adapter: :net_http)
          @adapter = adapter
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

            [operation, request, http_response, nil]
          rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Faraday::Error => e
            [operation, request, nil, TransportError.new(e.msg, e)]
          end
        end

        def cnx
          @cnx ||= Faraday.new do |c|
            c.adapter @adapter
          end
        end
      end

      class << self
        def simple
          backend = new
          backend.stack.add 'message.factory', SimpleMessageFactory.new
          backend.stack.add 'request.factory', SimpleRequestFactory.new
          backend.stack.add 'dispatcher', SimpleDispatcher.new
          backend.stack.add 'response.factory', SimpleResponseFactory.new
          backend.stack.add 'response.processor', -> (operation, request, response) { response }
          backend
        end

        def add_logger(backend, logger)
          backend.stack.after 'request.factory', 'request.logger', -> (operation, request) {
            logger.info request.xml
            [operation, request]
          }
          backend.stack.after 'dispatcher', 'response.logger', -> (operation, request, http_response, error) {
            logger.info http_response.body
            [operation, request, http_response, error]
          }
        end

        def logging(logger = Logger.new(STDOUT))
          backend = simple
          add_logger backend, logger
          backend
        end
      end
    end
  end
end
