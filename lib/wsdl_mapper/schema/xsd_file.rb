require 'wsdl/xmlSchema/parser'

module WsdlMapper
  module Schema
    class XsdFile
      attr_reader :root

      def initialize(readable)
        @root = WSDL::XMLSchema::Parser.new.parse(readable)
      end
    end
  end
end
