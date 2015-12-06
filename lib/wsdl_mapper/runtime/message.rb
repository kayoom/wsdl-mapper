module WsdlMapper
  module Runtime
    class Message
      attr_reader :address, :action, :envelope

      def initialize(address, action, envelope)
        @address = address
        @action = action
        @envelope = envelope
      end
    end
  end
end
