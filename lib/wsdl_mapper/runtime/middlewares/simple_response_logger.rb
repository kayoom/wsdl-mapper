require 'wsdl_mapper/runtime/middlewares/abstract_logger'

module WsdlMapper
  module Runtime
    module Middlewares
      class SimpleResponseLogger < AbstractLogger
        def call(operation, response)
          log "Response for #{operation.name}"
          log response.body

          [operation, response]
        end
      end
    end
  end
end
