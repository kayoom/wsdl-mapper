require 'faraday'
require 'logger'

require 'wsdl_mapper/runtime/errors'

module WsdlMapper
  module Runtime
    module Middlewares
      class SimpleDispatcher
        include WsdlMapper::Runtime::Errors

        attr_reader :cnx
        attr_accessor :logger

        # @param [Faraday::Connection] connection A faraday connection to use.
        def initialize(connection = Faraday.new, auto_retry = false, logger = nil)
          @cnx = connection
          @auto_retry = auto_retry
          @logger = logger || Logger.new(File::NULL).tap { |l| l.level = Logger::FATAL }
        end

        # Dispatches the request via the configured {#cnx} and returns the HTTP response.
        # @param [WsdlMapper::Runtime::Operation] operation
        # @param [WsdlMapper::Runtime::Request] request
        # @return [Array<WsdlMapper::Runtime::Operation, Faraday::Response>]
        # @raise [WsdlMapper::Runtime::Errors::TransportError] if a network error occured
        def call(operation, request)
          retries = 0
          begin
            http_response = execute_request(request)

            [operation, http_response]
          rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Faraday::Error => e
            if @auto_retry && retries <= @auto_retry
              retries += 1
              @logger.debug { "Error occured: #{e}, attempting retry #{retries}."}
              retry
            end
            raise TransportError.new(e.message, e, request)
          rescue HTTPError => e
            if @auto_retry && retries <= @auto_retry
              retries += 1
              @logger.debug { "Error occured: #{e}, attempting retry #{retries}."}
              retry
            end
            raise e
          end
        end

        def execute_request(request)
          http_response = cnx.post do |c|
            c.url request.url
            c.body = request.xml

            request.http_headers.each do |key, val|
              c[key] = val
            end
          end

          if http_response.status.to_s !~ /^2/
            raise HTTPError.new(http_response.status, http_response.body, nil, request)
          end

          http_response
        end
      end
    end
  end
end
