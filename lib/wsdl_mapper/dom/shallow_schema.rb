require 'wsdl_mapper/dom/type_base'

module WsdlMapper
  module Dom
    module ShallowSchema
      attr_accessor :namespace

      def types
        @types ||= Hash.new do |h, k|
          h[k] = build k
        end
      end

      def [] name
        types[name.to_s]
      end

      def build name
        new Name.new(namespace, name.to_s)
      end

      include Enumerable

      def each &block
        types.values.each &block
      end

      def builtin? name
        return name.ns == namespace
      end
    end
  end
end
