require 'wsdl_mapper/svc_desc/wsdl11/base'

module WsdlMapper
  module SvcDesc
    module Wsdl11
      class PortType < Base
        class Operation < Base
          attr_accessor :input, :output, :faults, :type

          def initialize(name)
            super name
            @faults = WsdlMapper::Dom::Directory.new
          end

          def add_fault(fault)
            @faults[fault.name] = fault
          end

          def each_fault(&block)
            @faults.each_value &block
          end

          def get_fault(name)
            @faults[name]
          end
        end

        class InputOutput < Base
          attr_accessor :message_name, :message
        end

        def initialize(name)
          super name
          @operations = WsdlMapper::Dom::Directory.new do |name|
            []
          end
        end

        def each_operation(&block)
          @operations.each_value.to_a.flatten.each &block
        end

        def add_operation(operation)
          @operations[operation.name] << operation
        end

        def get_operations(name)
          @operations[name]
        end

        def get_operation(name)
          @operations[name].first
        end

        def find_operation(name, input_name, output_name)
          get_operations(name).find do |op|
            op.input.name == input_name && op.output.name == output_name
          end
        end
      end
    end
  end
end
