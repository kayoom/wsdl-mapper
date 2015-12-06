require 'wsdl_mapper/runtime/backend_base'
require 'uri'
require 'net/http'

module WsdlMapper
  module Runtime
    class SimpleHttpBackend < BackendBase
      class Request
        attr_reader :message, :http_headers
        attr_accessor :url, :xml

        def initialize(message)
          @message = message
          @http_headers = {}
        end

        def https?
          @url.scheme == 'https'
        end
      end

      class Response
        attr_reader :status, :body
        attr_accessor :envelope

        def initialize(status, body)
          @status = status
          @body = body
        end
      end

      def build_request(operation, body, *args)
        message = operation.new_input body: body
        request = Request.new message
        request.xml = operation.input_s8r.to_xml(message.envelope)
        request.url = URI(message.address)

        request
      end

      def dispatch(operation, body, *args)
        request = build_request operation, body, *args

        post = Net::HTTP::Post.new request.url
        post.body = request.xml
        request.http_headers.each do |key, val|
          post[key] = val
        end

        http_response = Net::HTTP.start request.url.host, request.url.port, use_ssl: request.https? do |http|
          http.request post
        end

        response = Response.new http_response.code, http_response.body
        puts http_response.body
        response.envelope = operation.output_d10r.from_xml response.body
        response
      end
    end
  end
end
