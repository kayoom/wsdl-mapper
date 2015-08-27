module WsdlMapper
  module Dom
    class Bounds
      def initialize min: 0, max: 0, nillable: false
        @min, @max, @nillable = min, max, nillable
      end
    end
  end
end
