module WsdlMapper
  module Runtime
    class Request
      attr_reader :message, :http_headers
      attr_accessor :url, :xml

      # @!attribute message
      #   @return [WsdlMapper::Runtime::Message] The message to send
      # @!attribute http_headers
      #   @return [Hash] A hash of HTTP headers to set
      # @!attribute url
      #   @return [String] URL of the SOAP service
      # @!attribute xml
      #   @return [String] The serialized `message`

      # @param [WsdlMapper::Runtime::Message] message
      def initialize(message)
        @message = message
        @http_headers = {}
      end

      # Adds an HTTP header to the request
      # @param [String] key
      # @param [String] value
      def add_http_header(key, value)
        @http_headers[key] = value
      end

      # @return [true, false]
      def https?
        @url.scheme == 'https'
      end
    end
  end
end
