require 'nokogiri'

module WsdlMapper
  module Schema
    class SimpleImportResolver
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
