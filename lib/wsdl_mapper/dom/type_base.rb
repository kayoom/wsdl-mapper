require 'wsdl_mapper/dom/documentation'

module WsdlMapper
  module Dom
    class TypeBase
      attr_reader :name
      attr_accessor :documentation

      def initialize name
        @name = name
        @documentation = Documentation.new
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

      def self.to_proc
        -> (obj) { obj.is_a? self }
      end
    end
  end
end
