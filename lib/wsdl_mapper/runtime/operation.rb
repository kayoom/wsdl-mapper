require 'wsdl_mapper/svc_desc/envelope'
require 'wsdl_mapper/runtime/message'

module WsdlMapper
  module Runtime
    class Operation
      attr_reader :name, :operation_name

      def initialize(api, service, port)
        @api = api
        @service = service
        @port = port
        @soap_action = nil
        @name = nil
        @operation_name = nil
        @requires = []
        @loaded = false
      end

      def new_input(header: {}, body: {})
        load_requires
      end

      def new_output(header: {}, body: {})
        load_requires
      end

      def new_envelope(header, body)
        WsdlMapper::SvcDesc::Envelope.new header: header, body: body
      end

      def new_message(header, body)
        Message.new @port._soap_address, @soap_action, new_envelope(header, body)
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

      def load_requires
        return if @loaded

        @requires.each do |req|
          require req
        end
        @loaded = true
      end
    end
  end
end
