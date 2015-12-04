module WsdlMapper
  module Deserializers
    class Frame
      attr_reader :name, :parent, :attrs, :base, :mapping, :namespaces, :children, :type_name
      attr_accessor :text, :object

      def initialize(name, type_name, attrs, parent, namespaces, base, mapping)
        @name = name
        @type_name = type_name
        @parent = parent
        @attrs = attrs
        @namespaces = namespaces
        @base = base
        @mapping = mapping
        @children = []
      end

      def start
        if @mapping
          @mapping.start @base, self
        end
      end

      def end
        if @mapping
          @mapping.end @base, self
        end
      end
    end
  end
end
