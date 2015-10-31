module WsdlMapper
  module DomGeneration
    class Context
      def initialize target_path
        @target_path = target_path
      end

      def path_for type_name
        path = path_join type_name.file_path
        ensure_path_exists path

        File.join path, type_name.file_name
      end

      def path_join *paths
        File.join @target_path, *paths
      end

      private
      def ensure_path_exists path
        FileUtils.mkpath path
      end
    end
  end
end
