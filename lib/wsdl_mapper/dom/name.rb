module WsdlMapper
  module Dom
    class Name
      attr_reader :ns, :name

      def initialize ns, name
        @ns, @name = ns, name
      end

      def eql? other
        name == other.name && ns == other.ns
      end

      def == other
        eql? other
      end

      def hash
        [ns, name].hash
      end
    end
  end
end
