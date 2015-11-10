require 'wsdl_mapper/svc_desc/wsdl11/base'

module WsdlMapper
  module SvcDesc
    module Wsdl11
      class PortType < Base
        class Operation < Base
          attr_accessor :input_message_name, :output_message_name
          attr_accessor :input_message, :output_message
        end

        def initialize name
          super name
          @operations = WsdlMapper::Dom::Directory.new
        end

        def each_operation &block
          @operations.each_value &block
        end

        def add_operation operation
          @operations[operation.name] = operation
        end
      end
    end
  end
end
