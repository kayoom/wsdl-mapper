module WsdlMapper
  module Runtime
    module Errors
      class Error < ::StandardError
        attr_reader :cause

        def initialize(msg, cause = $!)
          super msg
          @cause = cause
        end
      end

      class TransportError < Error
        attr_reader :request

        def initialize(msg, cause = $!, request = nil)
          super(msg, cause)
          @request = request
        end
      end

      class SoapFault < Error
        attr_reader :fault

        def initialize(fault, cause = $!)
          super fault.string, cause
          @fault = fault
        end
      end
    end
  end
end
