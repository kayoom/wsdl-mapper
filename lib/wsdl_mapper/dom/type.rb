module WsdlMapper
  module Dom
    class Type
      attr_reader :name
      attr_reader :properties

      def initialize name
        @name = name
        @properties = []
      end

    end
  end
end
