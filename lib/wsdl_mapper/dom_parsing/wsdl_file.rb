require 'wsdl/parser'

module WsdlMapper
  module DomParsing
    class WsdlFile
      attr_reader :root

      def initialize(readable)
        @root = WSDL::Parser.new.parse(readable)
      end
    end
  end
end
