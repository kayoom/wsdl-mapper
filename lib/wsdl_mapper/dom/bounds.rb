module WsdlMapper
  module Dom
    class Bounds
      attr_reader :min, :max, :nillable

      def initialize min: nil, max: nil, nillable: nil
        @min, @max, @nillable = min, max, nillable
      end
    end
  end
end
