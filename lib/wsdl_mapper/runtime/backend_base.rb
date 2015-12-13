require 'wsdl_mapper/runtime/errors'
require 'wsdl_mapper/runtime/middleware_stack'
require 'uri'

module WsdlMapper
  module Runtime
    class BackendBase
      include WsdlMapper::Runtime::Errors

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

      class SimpleResponseFactory
        def call(operation, request, http_response, error)
          if http_response
            response = Response.new http_response.status, http_response.body
            response.envelope = operation.output_d10r.from_xml response.body

            [operation, request, response, error]
          else
            [operation, request, nil, error]
          end
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
    end
  end
end
