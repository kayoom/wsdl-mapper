require 'wsdl/parser'

module WsdlMapper
  module Schema
    class WsdlFile
      attr_reader :root

      def initialize(readable)
        @root = WSDL::Parser.new.parse(readable)
      end
    end
  end
end
