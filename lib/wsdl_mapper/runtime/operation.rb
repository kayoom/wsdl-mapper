require 'wsdl_mapper/svc_desc/envelope'
require 'wsdl_mapper/runtime/message'

module WsdlMapper
  module Runtime
    # @abstract
    # noinspection RubyUnusedLocalVariable
    class Operation
      attr_reader :name, :operation_name

      # @param [WsdlMapper::Runtime::Api] api
      # @param [WsdlMapper::Runtime::Service] service
      # @param [WsdlMapper::Runtime::Port] port
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

      # @abstract
      # @param [Hash<Symbol, Object>] header Keyword arguments for the corresponding input message header
      # @param [Hash<Symbol, Object>] body Keyword arguments for the corresponding input message body
      def new_input(header: {}, body: {})
        load_requires
        nil
      end

      # @abstract
      # @param [Hash<Symbol, Object>] header Keyword arguments for the corresponding output message header
      # @param [Hash<Symbol, Object>] body Keyword arguments for the corresponding output message body
      def new_output(header: {}, body: {})
        load_requires
        nil
      end

      # @return [WsdlMapper::SvcDesc::Envelope]
      # @param [WsdlMapper::Runtime::Header] header
      # @param [WsdlMapper::Runtime::Body] body
      def new_envelope(header, body)
        WsdlMapper::SvcDesc::Envelope.new(header: header, body: body)
      end

      # @param [WsdlMapper::Runtime::Header] header
      # @param [WsdlMapper::Runtime::Body] body
      # @return [WsdlMapper::Runtime::Message]
      def new_message(header, body)
        Message.new(@port._soap_address, @soap_action, new_envelope(header, body))
      end

      # @abstract
      # @return [WsdlMapper::Runtime::InputS8r] The serializer for this operations input message
      def input_s8r
        load_requires
      end

      # @abstract
      # @return [WsdlMapper::Runtime::OutputS8r] The serializer for this operations output message
      def output_s8r
        load_requires
      end

      # @abstract
      # @return [WsdlMapper::Runtime::InputD10r] The deserializer for this operations input message
      def input_d10r
        load_requires
      end

      # @abstract
      # @return [WsdlMapper::Runtime::OutputD10r] The deserializer for this operations output message
      def output_d10r
        load_requires
      end

      # Dynamically loads the required classes (API types and serializers)
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
