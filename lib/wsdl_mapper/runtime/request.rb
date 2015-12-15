module WsdlMapper
  module Runtime
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
  end
end
