module WsdlMapper
  module Generation
    class Result
      class ModuleTreeNode
        attr_reader :type_name, :children

        def initialize type_name
          @type_name = type_name
          @children = []
        end

        def leaf?
          @children.empty?
        end
      end

      attr_reader :files, :module_tree, :schema

      def initialize schema
        @files = []
        @module_tree = []
        @schema = schema
      end

      def add_type type_name
        modules = type_name.parents.reverse

        children = @module_tree
        modules.each do |mod|
          node = children.find { |n| n.type_name == mod }
          unless node
            node = ModuleTreeNode.new mod
            children << node
          end
          children = node.children
        end
        node = ModuleTreeNode.new type_name
        children << node
        self
      end
    end
  end
end
