module WsdlMapper
  module Dom
    class Schema
      attr_reader :types

      def initialize
        @types = {}
      end

      def add_type type
        @types[type.name] = type
      end
    end
  end
end
