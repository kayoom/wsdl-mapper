require 'wsdl_mapper/generation/base'

module WsdlMapper
  module Generation
    class DefaultModuleGenerator < Base
      def initialize(generator)
        @generator = generator
        @context = generator.context
      end

      def generate(module_node, result)
        return self if module_node.leaf?

        append_file_for module_node.type_name, result do |f|
          module_node.children.each do |child|
            f.require child.type_name.require_path
          end
        end

        module_node.children.each do |child|
          generate child, result
        end
        self
      end

      protected
      def get_formatter(io)
        @generator.get_formatter io
      end
    end
  end
end
