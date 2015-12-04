require 'wsdl_mapper/svc_desc/envelope'

module WsdlMapper
  module Runtime
    class Operation
      def initialize(api, service, port)
        @_api = api
        @_service = service
        @_port = port
        @_requires = []
        @_loaded = false
      end

      def new_input(header: {}, body: {})
        load_requires
      end

      def new_output(header: {}, body: {})
        load_requires
      end

      def new_message(header, body)
        WsdlMapper::SvcDesc::Envelope.new header: header, body: body
      end

      def input_s8r
        load_requires
      end

      def output_s8r
        load_requires
      end

      def input_d10r
        load_requires
      end

      def output_d10r
        load_requires
      end

      protected
      def load_requires
        return if @_loaded

        @_requires.each do |req|
          require req
        end
        @_loaded = true
      end
    end
  end
end
