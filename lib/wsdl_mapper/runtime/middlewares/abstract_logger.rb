require 'logger'

module WsdlMapper
  module Runtime
    module Middlewares
      class AbstractLogger
        def initialize(logger = Logger.new(STDOUT), log_level: Logger::DEBUG)
          @logger = logger
          @log_level = log_level
        end

        protected
        def log(msg)
          @logger.add(@log_level, msg)
        end
      end
    end
  end
end
