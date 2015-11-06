require 'nokogiri'

require 'wsdl_mapper/schema/abstract_resolver'
require 'uri'

module WsdlMapper
  module Schema
    class UrlResolver < AbstractResolver
      def resolve url
        uri = URI.parse url
        Nokogiri::XML::Document.parse uri.read
      end
    end
  end
end
