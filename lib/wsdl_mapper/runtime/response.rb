module WsdlMapper
  module Runtime
    class Response
      attr_reader :status, :body, :http_headers
      attr_accessor :envelope

      # @!attribute status
      #   @return [Fixnum]
      # @!attribute body
      #   @return [String]
      # @!attribute http_headers
      #   @return [Hash]
      # @!attribute envelope
      #   @return [WsdlMapper::SvcDesc::Envelope] The deserialized body

      # @param [Fixnum] status HTTP response code
      # @param [String] body HTTP response body
      # @param [Hash] http_headers HTTP response headers
      def initialize(status, body, http_headers)
        @status = status
        @body = body
        @http_headers = http_headers
      end
    end
  end
end

