module WsdlMapper
  module Generation
    class GeneratorBase
      def initialize generator
        @generator = generator
      end

      protected
      def write_requires f, requires
        if requires.any?
          requires.each do |req|
            f.require req
          end
          f.after_requires
        end
      end

      def close_modules f, modules
        modules.each { f.end }
      end

      def open_modules f, modules
        modules.each do |mod|
          f.begin_module mod.module_name
        end
      end
    end
  end
end
