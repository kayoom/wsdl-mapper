module WsdlMapper
  module SvcDesc
    class Fault
      attr_accessor :code, :string, :actor, :detail

      # @!attribute code
      #   @return [String]
      # @!attribute string
      #   @return [String]
      # @!attribute actor
      #   @return [String]
      # @!attribute detail
      #   @return [Object]

      # @param [String] code
      # @param [String] string
      # @param [String] actor
      # @param [Object] detail
      def initialize(code: nil, string: nil, actor: nil, detail: nil)
        @code = code
        @string = string
        @actor = actor
        @detail = detail
      end
    end
  end
end
