require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

require 'base64'
require 'stringio'

module WsdlMapper
  module TypeMapping
    Base64Binary = Base.new do
      register_xml_types %w[
        base64Binary
      ]

      def to_ruby string
        StringIO.new Base64.decode64 string
      end

      def to_xml io
        Base64.encode64 io.read
      end

      def ruby_type
        ::StringIO
      end

      def requires
        ['stringio']
      end
    end
  end
end
