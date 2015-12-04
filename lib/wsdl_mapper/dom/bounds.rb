module WsdlMapper
  module Dom
    class Bounds
      attr_accessor :min, :max, :nillable

      def initialize(min: nil, max: nil, nillable: nil)
        @min, @max, @nillable = min, max, nillable
      end

      def dup
        Bounds.new min: @min, max: @max, nillable: @nillable
      end
    end
  end
end
