module WsdlMapper
  module Generation
    class Context
      # @param [String] target_path Absolute root path
      def initialize(target_path)
        @target_path = target_path
      end

      # Returns the absolute path for a specified `type_name`. If the directories do not exist,
      # it will create them before returning.
      # @param [TypeName] type_name
      # @return [String] The full absolute file path for the specified `type_name`
      def path_for(type_name)
        path = path_join type_name.file_path

        File.join path, type_name.file_name
      end

      # Returns an absolute path for the specified `paths`, creates it, if it doesn't exist.
      # @param [Array<String>] paths An array of paths
      # @return [String] An absolute path as string
      def path_join(*paths)
        path = File.join @target_path, *paths
        ensure_path_exists path

        path
      end

      private
      def ensure_path_exists(path)
        FileUtils.mkpath path
      end
    end
  end
end
