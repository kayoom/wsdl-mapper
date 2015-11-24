require 'wsdl_mapper/dom/directory'

module WsdlMapper
  module Runtime
    class SoapMessage
      attr_accessor :body
      attr_reader :headers

      def initialize
        @headers = []
      end

    end
  end
end
