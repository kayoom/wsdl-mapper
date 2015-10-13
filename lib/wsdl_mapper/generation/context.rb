module WsdlMapper
  module Generation
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

      # SIC
      # TODO: type writer object with: path/name, io, infos for requires, modules
      #
      # given: Foo::Bar::Baz type -> 'foo/bar/baz.rb'

      # file foo/bar/baz.rb with class Foo::Bar::Baz
      # file foo/bar.rb with module Foo::Bar and require 'foo/bar/baz'
      # file foo.rb with module Foo and require 'foo/bar'

      private
      def ensure_path_exists path
        FileUtils.mkpath path
      end
    end
  end
end
