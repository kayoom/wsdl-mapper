module WsdlMapper
  module Dom
    class Name
      attr_reader :ns, :name

      def initialize ns, name
        @ns, @name = ns, name
      end

      def eql? other
        self.class == other.class && name == other.name && ns == other.ns
      end

      def == other
        eql? other
      end

      def hash
        [ns, name].hash
      end

      def to_s
        name unless ns

        "#{ns}##{name}"
      end
    end
  end
end
