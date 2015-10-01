module WsdlMapper
  module Naming
    class TypeName
      attr_reader :class_name, :module_path, :file_name, :file_path

      def initialize class_name, module_path, file_name, file_path
        @class_name = class_name
        @module_path = module_path
        @file_name = file_name
        @file_path = file_path
      end
    end
  end
end
