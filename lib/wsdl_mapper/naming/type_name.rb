module WsdlMapper
  module Naming
    # Class to represent the (ruby) type name for an XML (complex or simple) type.
    # This includes the ruby class name and module hierarchy, as well as file name + file path.
    class TypeName
      # @!attribute [r] class_name
      #   @return [String] Class name of the ruby class (to generate), without enclosing modules. E.g. `"Note"` for
      #                    `::ModuleA::ModuleB::Note`.
      # @!attribute [r] module_path
      #   @return [Array<String>] Hierarchy of enclosing ruby modules. E.g. ["ModuleA", "ModuleB"] for
      #                    `::ModuleA::ModuleB::Note`.
      # @!attribute [r] file_name
      #   @return [String] File name where to put the ruby class into (including the '.rb' extension). E.g. "note.rb"
      # @!attribute [r] file_path
      #   @return [Array<String>] File path (without file name) as array, e.g. ["module_a", "module_b"]
      # @!attribute [rw] parent
      #   @return [TypeName] Parent {TypeName}, usually representing a module, that contains several classes.
      attr_reader :class_name, :module_path, :file_name, :file_path
      attr_accessor :parent
      alias_method :module_name, :class_name

      # Initialize a new instance with the given names / paths
      #
      # @param [String] class_name
      # @param [Array<String>] module_path
      # @param [String] file_name
      # @param [Array<String>] file_path
      def initialize(class_name, module_path, file_name, file_path)
        @class_name = class_name
        @module_path = module_path
        @file_name = file_name
        @file_path = file_path
      end

      # Returns the hierarchy of parents.
      #
      # @return [Array<TypeName>] List of ancestors, with the immediate {#parent} as first element. `[]` if this
      #                           is at root level.
      def parents
        @parents ||= if parent.nil?
          []
        else
          [parent] + parent.parents
        end
      end

      # Returns the path necessary to require this type later on.
      #
      # @return [String] Full (relative) path (excluding the extension) to use in a `require` statement.
      #                  E.g. `"module_a/module_b/note"`
      def require_path
        @require_path ||= File.join *@file_path, File.basename(@file_name, '.rb')
      end

      # Full qualified ruby class name, including enclosing modules and root module prefix, e.g.
      # `"::ModuleA::ModuleB::Note"`
      # @return [String]
      def name
        @name ||= ['', *@module_path, @class_name] * '::'
      end

      # Determines if this type name is equal to `other`. Two type names are considered
      # equal, if their {TypeName#name} is equal.
      # @param [TypeName] other Other type name to compare to
      # @return [true, false]
      def eql?(other)
        self.class == other.class && name == other.name
      end
      alias_method :==, :eql?

      # @!visibility private
      def hash
        [self.class, name].hash
      end
    end
  end
end
