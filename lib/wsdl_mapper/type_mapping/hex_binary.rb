require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

require 'stringio'

module WsdlMapper
  module TypeMapping
    HexBinary = Base.new do
      register_xml_types %w[
        hexBinary
      ]

      def to_ruby string
        StringIO.new [string.to_s.strip].pack("H*")
      end

      def to_xml io
        io.read.unpack("H*").first
      end
    end
  end
end
