require 'wsdl_mapper/type_mapping/base'
require 'wsdl_mapper/dom/builtin_type'

module WsdlMapper
  module TypeMapping
    Time = Base.new do
      register_xml_types %w[
        time
      ]

      def to_ruby string
        zone = ::Date._parse(string)[:zone]
        ::Time.parse(string.to_s).getlocal zone
      end

      def to_xml object
        object.strftime "%T%:z"
      end

      def ruby_type
        ::Time
      end

      def requires
        ['time']
      end
    end
  end
end
