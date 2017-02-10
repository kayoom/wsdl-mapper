module WsdlMapper
  module Dom
    # Represents a fully qualified name of an XML element, that means, it contains both the namespace,
    # and the local name
    class Name
      # @!attribute [r] ns
      #   @return [String] Namespace (URI) of this fully qualified name.

      # @!attribute [r] name
      #   @return [String] Local name of this fully qualified name.

      attr_reader :ns, :name

      # Initialize a new fully qualified name.
      # @param [String] ns
      # @param [String] name
      def initialize(ns, name)
        @ns, @name = ns, name
        @hash = [ns, name].hash
      end

      # Check if this fully qualified name is equal to `other`.
      # @param [Name] other Other name to compare to.
      # @return [true, false] true if `self` and `other` are equal both in namespace and in local name.
      def eql?(other)
        self.class == other.class && name == other.name && ns == other.ns
      end

      # @see {#eql?}
      def ==(other)
        eql? other
      end

      def hash
        @hash
      end

      # Returns the fully qualified name as string representation in the format
      # `"{namespace-uri}/local-name"`
      # @return [String] String representation of this FQN
      def to_s
        "{#{ns}}#{name}"
      end

      # Returns the namespace and local name as elements of a tuple / 2-element array:
      # `["namespace-uri", "local-name"]`
      # @return [Array<String>] An array containing namespace & local name.
      def to_a
        [ns, name]
      end

      # Gets the {Name} object for the given namespace and local name from the name cache to minimize the number of
      # strings + objects used.
      # @param [String] ns Namespace URI
      # @param [String] name Local name
      # @return [Name]
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
