module WsdlMapper
  module SvcDesc
    class Envelope
      attr_accessor :header, :body

      def initialize(header: nil, body: nil)
        @header = header
        @body = body
      end
    end
  end
end
