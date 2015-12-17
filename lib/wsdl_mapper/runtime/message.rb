module WsdlMapper
  module Runtime
    class Message
      attr_reader :address, :action, :envelope

      # @!attribute address
      #   @return [String]
      # @!attribute action
      #   @return [String]
      # @!attribute envelope
      #   @return [WsdlMapper::SvcDesc::Envelope]

      # @param [String] address
      # @param [String] action
      # @param [WsdlMapper::SvcDesc::Envelope] envelope
      def initialize(address, action, envelope)
        @address = address
        @action = action
        @envelope = envelope
      end
    end
  end
end
