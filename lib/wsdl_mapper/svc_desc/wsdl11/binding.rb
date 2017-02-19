require 'wsdl_mapper/svc_desc/wsdl11/base'

module WsdlMapper
  module SvcDesc
    module Wsdl11
      class Binding < Base
        class Operation < Base
          attr_accessor :soap_action, :input, :output, :target, :faults

          def initialize(name)
            super name
            @faults = WsdlMapper::Dom::Directory.new
          end

          def add_fault(fault)
            @faults[fault.name] = fault
          end

          def each_fault(&block)
            @faults.each_value(&block)
          end

          def get_fault(name)
            @faults[name]
          end
        end

        class InputOutput < Base
          attr_accessor :body, :message, :target

          def initialize(name)
            super name
            @headers = []
          end

          def add_header(header)
            @headers << header
          end

          def each_header(&block)
            @headers.each(&block)
          end
        end

        class Fault < Base
          attr_accessor :message, :soap_fault, :target
        end

        class SoapFault < Base
          attr_accessor :use

          def encoded?
            @use == 'encoded'
          end

          def literal?
            !encoded?
          end
        end

        class HeaderBase
          attr_accessor :use, :message_name, :part_name
          attr_accessor :message, :part, :namespace, :encoding_styles

          def encoded?
            @use == 'encoded'
          end

          def literal?
            !encoded?
          end
        end

        class Header < HeaderBase
          attr_reader :header_faults

          def initialize
            @header_faults = []
          end

          def add_header_fault(header_fault)
            @header_faults << header_fault
          end

          def each_header_fault(&block)
            @header_faults.each(&block)
          end
        end

        class HeaderFault < HeaderBase
        end

        class Body
          attr_accessor :use, :part_names
          attr_accessor :parts, :namespace, :encoding_styles

          def initialize
            @parts = []
            @part_names = []
            @encoding_styles = []
          end

          def encoded?
            @use == 'encoded'
          end

          def literal?
            !encoded?
          end
        end

        attr_accessor :style, :transport, :type_name, :type

        def initialize(name)
          super name

          @operations = WsdlMapper::Dom::Directory.new do |_|
            []
          end
        end

        def each_operation(&block)
          @operations.each_value.to_a.flatten.each(&block)
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

        def rpc?
          @style == 'rpc'
        end

        def document?
          !rpc?
        end
      end
    end
  end
end
