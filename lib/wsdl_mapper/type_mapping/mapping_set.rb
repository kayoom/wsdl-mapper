module WsdlMapper
  module TypeMapping
    class MappingSet
      def initialize
        @list = []
        @cache = Hash.new do |h, k|
          h[k] = get_mapping(k)
        end
      end

      def << mapping
        @list << mapping
        self
      end

      def find type
        @cache[type]
      end

      protected
      def get_mapping type
        @list.find { |m| m.maps? type }
      end
    end
  end
end
