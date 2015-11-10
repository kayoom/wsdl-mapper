require 'wsdl_mapper/svc_desc/wsdl11/base'

module WsdlMapper
  module SvcDesc
    module Wsdl11
      class Binding < Base
        class Operation < Base
          attr_accessor :soap_action, :input, :output
        end

        class InputOutput
          attr_accessor :header, :body
        end

        class HeaderBody
          attr_accessor :use, :message_name, :part_name
          attr_accessor :message, :part

          def encoded?
            @use == 'encoded'
          end

          def literal?
            !encoded?
          end
        end

        attr_accessor :style, :transport, :type_name, :type

        def initialize name
          super name
          @operations = WsdlMapper::Dom::Directory.new
        end

        def rpc?
          @style == 'rpc'
        end

        def document?
          !rpc?
        end

        def add_operation operation
          @operations[operation.name] = operation
        end

        def each_operation &block
          @operations.each_value &block
        end
      end
    end
  end
end
