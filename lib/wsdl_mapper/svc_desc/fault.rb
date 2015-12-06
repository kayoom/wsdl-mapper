module WsdlMapper
  module SvcDesc
    class Fault
      attr_accessor :code, :string, :actor, :detail

      def initialize(code: nil, string: nil, actor: nil, detail: nil)
        @code = code
        @string = string
        @actor = actor
        @detail = detail
      end
    end
  end
end
