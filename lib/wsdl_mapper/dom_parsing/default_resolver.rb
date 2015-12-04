require 'wsdl_mapper/dom_parsing/abstract_resolver'

require 'wsdl_mapper/dom_parsing/local_file_resolver'
require 'wsdl_mapper/dom_parsing/url_resolver'

module WsdlMapper
  module DomParsing
    class DefaultResolver < AbstractResolver

      def initialize(path)
        @file_resolver = LocalFileResolver.new path
        @url_resolver = UrlResolver.new
      end

      def resolve(name)
        if url? name
          @url_resolver.resolve name
        else
          # TODO: absolute paths?
          @file_resolver.resolve name
        end
      end

      protected
      def url?(name)
        name =~ /^https?\:\/\//
      end
    end
  end
end
