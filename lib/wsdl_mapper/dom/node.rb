module WsdlMapper
  module Dom
    class Node
      attr_reader :children
      attr_accessor :parent

      def initialize parent
        @parent = parent
        @children = []
      end

      def add_child node
        node.parent = self
        children << node
        self
      end

      def root?
        parent.nil?
      end

      def leaf?
        children.empty?
      end
    end
  end
end
