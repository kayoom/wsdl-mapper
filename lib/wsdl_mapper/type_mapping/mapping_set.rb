module WsdlMapper
  module TypeMapping
    class MappingSet
      def initialize
        @list = []
        @cache = Hash.new do |h, k|
          h[k] = get_mapping(k)
        end
      end

      def <<(mapping)
        @list << mapping
        self
      end

      def find(type)
        @cache[type]
      end

      def find!(type)
        find(type) || raise(ArgumentError.new("Unknown type: #{type}"))
      end

      def dup
        other = self.class.new
        @list.each do |mapping|
          other << mapping
        end
        other
      end

      # TODO: test
      def remove(mapping)
        @list.delete mapping
        @cache.delete_if { |_, m| m == mapping }
      end

      def self.default
        @default ||= MappingSet.new
      end

      def to_ruby(type, value)
        find!(type).to_ruby value
      end

      def to_xml(type, value)
        find!(type).to_xml value
      end

      def ruby_type(type)
        find!(type).ruby_type
      end

      def requires(type)
        find!(type).requires
      end

      protected
      def get_mapping(type)
        @list.find { |m| m.maps? type }
      end
    end
  end
end
