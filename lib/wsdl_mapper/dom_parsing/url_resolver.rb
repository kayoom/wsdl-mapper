require 'nokogiri'

require 'wsdl_mapper/dom_parsing/abstract_resolver'
require 'uri'
require 'open-uri'

module WsdlMapper
  module DomParsing
    class UrlResolver < AbstractResolver
      def resolve(url)
        uri = URI.parse url
        Nokogiri::XML::Document.parse uri.read
      end
    end
  end
end
