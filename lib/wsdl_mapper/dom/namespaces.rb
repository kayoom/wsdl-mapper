module WsdlMapper
  module Dom
    class Namespaces
      include Enumerable

      def initialize prefix: 'ns'
        @namespaces = {}
        @default = nil
        @i = 0
        @prefix = prefix
      end

      attr_accessor :default

      def set prefix, url
        @namespaces[prefix.to_s] = url
      end
      alias_method :[]=, :set

      def get prefix
        @namespaces[prefix.to_s]
      end
      alias_method :[], :get

      def prefix_for url
        return nil if url.nil?
        return nil if url == @default
        prefix = @namespaces.key(url)
        return prefix if prefix
        prefix = @prefix + @i.to_s
        @i += 1
        set prefix, url
        prefix
      end

      def each &block
        enum = Enumerator.new do |y|
          y << [nil, default] if default
          @namespaces.each do |prefix, url|
            y << [prefix, url]
          end
        end

        block_given? ? enum.each(&block) : enum
      end

      def self.for hash
        ns = new
        hash.each do |prefix, url|
          ns[prefix] = url
        end
        ns
      end
    end
  end
end
