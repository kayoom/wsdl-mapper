module WsdlMapper
  module Generation
    class Result
      class ModuleTreeNode
        attr_reader :type_name, :children

        def initialize(type_name)
          @type_name = type_name
          @children = []
        end

        def leaf?
          @children.empty?
        end
      end

      attr_reader :files, :module_tree, :schema, :type_names, :description

      def initialize(schema: nil, description: nil)
        @files = []
        @module_tree = []
        @type_names = []
        @description = description
        @schema = schema
      end

      def add_type(type_name)
        @type_names << type_name
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

      class << self
        def merge(result, *results)
          res = new schema: result.schema, description: result.description
          results.each do |r|
            r.type_names.each do |type_name|
              res.add_type type_name
            end
            r.files.each do |f|
              res.files << f
            end
          end
          res
        end
      end
    end
  end
end
