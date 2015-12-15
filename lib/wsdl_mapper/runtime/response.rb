module WsdlMapper
  module Runtime
    class Response
      attr_reader :status, :body
      attr_accessor :envelope, :error

      def initialize(status, body)
        @status = status
        @body = body
      end
    end
  end
end

