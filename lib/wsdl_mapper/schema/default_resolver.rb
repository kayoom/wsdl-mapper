require 'wsdl_mapper/schema/abstract_resolver'

require 'wsdl_mapper/schema/local_file_resolver'
require 'wsdl_mapper/schema/url_resolver'

module WsdlMapper
  module Schema
    class DefaultResolver < AbstractResolver

      def initialize path
        @file_resolver = LocalFileResolver.new path
        @url_resolver = UrlResolver.new
      end

      def resolve name
        if url? name
          @url_resolver.resolve name
        else
          # TODO: absolute paths?
          @file_resolver.resolve name
        end
      end

      protected
      def url? name
        name =~ /^https?\:\/\//
      end
    end
  end
end
