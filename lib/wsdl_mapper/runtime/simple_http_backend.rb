require 'wsdl_mapper/runtime/backend_base'
require 'wsdl_mapper/runtime/middleware_stack'
require 'wsdl_mapper/runtime/errors'
require 'uri'
require 'net/http'
require 'logger'

module WsdlMapper
  module Runtime
    class SimpleHttpBackend < BackendBase
      include WsdlMapper::Runtime::Errors

      class SimpleMessageFactory
        def call(operation, body, args)
          message = operation.new_input body: body

          [operation, message]
        end
      end

      class SimpleRequestFactory
        def call(operation, message)
          request = Request.new message
          request.xml = operation.input_s8r.to_xml(message.envelope)
          request.url = URI(message.address)
          request.add_http_header 'SOAPAction', message.action
          request.add_http_header 'Content-Type', 'text/xml'

          [operation, request]
        end
      end

      class SimpleDispatcher
        def call(operation, request)
          post = Net::HTTP::Post.new request.url
          post.body = request.xml
          request.http_headers.each do |key, val|
            post[key] = val
          end

          begin
            http_response = Net::HTTP.start request.url.host, request.url.port, use_ssl: request.https? do |http|
              http.request post
            end

            [operation, request, http_response, nil]
          rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
            Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e

            [operation, request, nil, TransportError.new(e.msg, e)]
          end
        end
      end

      class SimpleResponseFactory
        def call(operation, request, http_response, error)
          if http_response
            response = Response.new http_response.code, http_response.body
            response.envelope = operation.output_d10r.from_xml response.body

            [operation, request, response, error]
          else
            [operation, request, nil, error]
          end
        end
      end

      class Request
        attr_reader :message, :http_headers
        attr_accessor :url, :xml

        def initialize(message)
          @message = message
          @http_headers = {}
        end

        def add_http_header(key, value)
          @http_headers[key] = value
        end

        def https?
          @url.scheme == 'https'
        end
      end

      class Response
        attr_reader :status, :body
        attr_accessor :envelope, :error

        def initialize(status, body)
          @status = status
          @body = body
        end
      end

      attr_reader :stack

      def initialize
        @stack = MiddlewareStack.new
      end

      def dispatch(operation, body, **options)
        stack.inject([operation, body, options]) do |obj, middleware|
          middleware.call *obj
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
