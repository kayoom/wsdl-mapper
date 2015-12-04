module WsdlMapper
  module Dom
    class Name
      attr_reader :ns, :name

      def initialize(ns, name)
        @ns, @name = ns, name
        @hash = [ns, name].hash
      end

      def eql?(other)
        self.class == other.class && name == other.name && ns == other.ns
      end

      def ==(other)
        eql? other
      end

      def hash
        @hash
      end

      def to_s
        "{#{ns}}#{name}"
      end

      def to_a
        [ns, name]
      end

      def self.get(ns, name)
        @cache ||= Hash.new do |h, k|
          h[k] = Hash.new do |h2, k2|
            h2[k2] = new k, k2
          end
        end

        name = name.to_s unless name.is_a?(String)
        @cache[ns][name]
      end
    end
  end
end
