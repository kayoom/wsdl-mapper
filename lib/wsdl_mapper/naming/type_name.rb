module WsdlMapper
  module Naming
    class TypeName
      attr_reader :class_name, :module_path, :file_name, :file_path
      attr_accessor :parent
      alias_method :module_name, :class_name

      def initialize class_name, module_path, file_name, file_path
        @class_name = class_name
        @module_path = module_path
        @file_name = file_name
        @file_path = file_path
      end

      def parents
        @parents ||= if parent.nil?
          []
        else
          [parent] + parent.parents
        end
      end

      def require_path
        @require_path ||= File.join *@file_path, File.basename(@file_name, ".rb")
      end

      def name
        @name ||= ['', *@module_path, @class_name] * "::"
      end

      def eql? other
        self.class == other.class && name == other.name
      end

      def == other
        eql? other
      end

      def hash
        [self.class, name].hash
      end
    end
  end
end
