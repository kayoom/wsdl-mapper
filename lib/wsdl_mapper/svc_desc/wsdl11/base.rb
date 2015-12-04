require 'wsdl_mapper/dom/directory'

module WsdlMapper
  module SvcDesc
    module Wsdl11
      class Base
        attr_reader :name
        attr_accessor :documentation

        def initialize(name)
          @name = name
        end
      end
    end
  end
end
