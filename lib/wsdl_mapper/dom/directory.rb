module WsdlMapper
  module Dom
    class Directory
      def initialize &block
        block ||= -> (a, b) { nil }
        @data = Hash.new do |h, k|
          h[k] = Hash.new do |h2, k2|
            h2[k2] = block[k, k2]
          end
        end
      end

      def get name
        @data[name.ns][name.name]
      end
      alias_method :[], :get

      def set name, value
        @data[name.ns][name.name] = value
      end
      alias_method :[]=, :set
    end
  end
end
