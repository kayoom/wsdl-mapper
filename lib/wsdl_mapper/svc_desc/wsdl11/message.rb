require 'wsdl_mapper/svc_desc/wsdl11/base'

module WsdlMapper
  module SvcDesc
    module Wsdl11
      class Message < Base
        class Part < Base
          attr_accessor :element_name, :type_name, :element, :type
        end

        attr_reader :parts

        def initialize name
          super name
          @parts = WsdlMapper::Dom::Directory.new
        end

        def add_part part
          @parts[part.name] = part
        end

        def each_part &block
          @parts.each_value &block
        end

        def get_part name
          @parts[name]
        end
      end
    end
  end
end
