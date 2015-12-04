module WsdlMapper
  module Generation
    # @abstract
    class AbstractFormatter
      def initialize(io)
        @io = io
      end

      def in_class(name)
        raise NotImplementedError
      end

      def in_sub_class(name)
        raise NotImplementedError
      end

      def begin_modules(names)
        raise NotImplementedError
      end

      def end_modules(names)
        raise NotImplementedError
      end

      def in_modules(names)
        raise NotImplementedError
      end

      def assignment(var_name, value)
        raise NotImplementedError
      end

      def call(name, *args)
        raise NotImplementedError
      end

      def next_statement
        raise NotImplementedError
      end

      def blank_line
        raise NotImplementedError
      end

      def blank_comment
        raise NotImplementedError
      end

      def block(statement, block_args, &block)
        raise NotImplementedError
      end

      def block_assignment(var_name, statement, block_args, &block)
        raise NotImplementedError
      end

      def statements(*statements)
        raise NotImplementedError
      end

      def after_requires
        raise NotImplementedError
      end

      def after_constants
        raise NotImplementedError
      end

      def statement(statement)
        raise NotImplementedError
      end

      def requires(path)
        raise NotImplementedError
      end

      def attr_accessors(*attrs)
        raise NotImplementedError
      end

      def begin_module(name)
        raise NotImplementedError
      end

      def begin_class(name)
        raise NotImplementedError
      end

      def begin_sub_class(name, super_name)
        raise NotImplementedError
      end

      def begin_def(name, *args)
        raise NotImplementedError
      end

      def in_def(name, *args)
        raise NotImplementedError
      end

      def literal_array(name, values)
        raise NotImplementedError
      end

      def assignments(*assigns)
        raise NotImplementedError
      end

      def end
        raise NotImplementedError
      end
    end
  end
end
