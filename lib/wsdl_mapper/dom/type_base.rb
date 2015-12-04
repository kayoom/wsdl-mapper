require 'wsdl_mapper/dom/documentation'

module WsdlMapper
  module Dom
    class TypeBase
      attr_reader :name
      attr_accessor :documentation

      def initialize(name)
        @name = name
        @documentation = Documentation.new
      end

      def hash
        name ? [self.class, name].hash : super
      end

      def ==(other)
        eql? other
      end

      def eql?(other)
        name ? (self.class == other.class && name == other.name) : super
      end

      def self.to_proc
        -> (obj) { obj.is_a? self }
      end
    end
  end
end
