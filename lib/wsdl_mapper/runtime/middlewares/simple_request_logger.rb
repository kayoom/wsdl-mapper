require 'wsdl_mapper/runtime/middlewares/abstract_logger'

module WsdlMapper
  module Runtime
    module Middlewares
      class SimpleRequestLogger < AbstractLogger
        def call(operation, request)
          log "Request for #{operation.name}"
          log "POST #{request.url}"
          log "SOAP-Action: #{request.message.action}"
          log request.xml

          [operation, request]
        end
      end
    end
  end
end
