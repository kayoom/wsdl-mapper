require 'wsdl_mapper/svc_desc/wsdl11/base'

module WsdlMapper
  module SvcDesc
    module Wsdl11
      class Service < Base
        class Port < Base
          attr_accessor :binding_name, :address_location
          attr_accessor :binding
        end

        def initialize name
          super name
          @ports = WsdlMapper::Dom::Directory.new
        end

        def add_port port
          @ports[port.name] = port
        end

        def each_port &block
          @ports.each_value &block
        end
      end
    end
  end
end
