require 'nokogiri'

require 'wsdl_mapper/schema/abstract_resolver'

module WsdlMapper
  module Schema
    class LocalFileResolver < AbstractResolver
      def initialize path
        @path = path
      end

      def resolve name
        path = File.join @path, name

        Nokogiri::XML::Document.parse File.read(path)
      end
    end
  end
end
