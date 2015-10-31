module WsdlMapper
  module DomGeneration
    class DefaultModuleGenerator
      def initialize generator
        @generator = generator
      end

      def generate module_node, result
        return self if module_node.leaf?

        file_name = @generator.context.path_for module_node.type_name

        File.open file_name, 'w' do |io|
          f = @generator.get_formatter io

          module_node.children.each do |child|
            f.require child.type_name.require_path
          end
        end

        module_node.children.each do |child|
          generate child, result
        end
        self
      end
    end
  end
end
