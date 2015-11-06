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
        n = name.is_a?(WsdlMapper::Dom::Name) ? name.name : name
        types[name]
      end

      def build name
        n = name.is_a?(WsdlMapper::Dom::Name) ? name : Name.get(namespace, name)
        new n
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
