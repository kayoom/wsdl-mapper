module WsdlMapper
  module Dom
    class Documentation
      attr_reader :default
      attr_accessor :app_info

      def initialize text = nil
        @default = text
      end

      def present?
        !@default.nil?
      end
    end
  end
end
