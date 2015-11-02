module WsdlMapper
  module Generation
    # @abstract
    class AbstractFormatter
      def initialize io
        @io = io
      end

      def next_statement
        raise NotImplementedError
      end

      def blank_line
        raise NotImplementedError
      end

      def after_requires
        raise NotImplementedError
      end

      def after_constants
        raise NotImplementedError
      end

      def statement statement
        raise NotImplementedError
      end

      def require path
        raise NotImplementedError
      end

      def attr_accessor *attrs
        raise NotImplementedError
      end

      def begin_module name
        raise NotImplementedError
      end

      def begin_class name
        raise NotImplementedError
      end

      def begin_sub_class name, super_name
        raise NotImplementedError
      end

      def begin_def name, args = []
        raise NotImplementedError
      end

      def literal_array values
        raise NotImplementedError
      end

      def assignment *assigns
        raise NotImplementedError
      end

      def end
        raise NotImplementedError
      end
    end
  end
end
