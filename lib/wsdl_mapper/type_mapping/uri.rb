require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

require 'uri'

module WsdlMapper
  module TypeMapping
    Uri = Base.new do
      register_xml_types %w[
        anyURI
      ]

      def to_ruby(string)
        URI(string)
      end

      def to_xml(object)
        case object
        when URI::Generic
          object.to_s
        else
          URI.escape object.to_s
        end
      end

      def ruby_type
        ::String
      end

      def requires
        ['uri']
      end
    end
  end
end
