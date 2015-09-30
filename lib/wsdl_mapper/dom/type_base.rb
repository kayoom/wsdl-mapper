module WsdlMapper
  module Dom
    class TypeBase
      attr_reader :name
      attr_accessor :documentation

      def initialize name
        @name = name
      end

      def hash
        [self.class, name].hash
      end

      def == other
        eql? other
      end

      def eql? other
        self.class == other.class && name == other.name
      end
    end
  end
end
