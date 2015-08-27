require 'wsdl/xmlSchema/parser'

module WsdlMapper
  module Schema
    class XsdFile
      attr_reader :schema, :complex_types, :simple_types

      def initialize(readable)
        @schema = WSDL::XMLSchema::Parser.new.parse(readable)

        @complex_types = @schema.collect_complextypes
        @simple_types = @schema.collect_simpletypes
      end
    end
  end
end
