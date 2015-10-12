module WsdlMapper
  module Generation
    class DefaultFormatter
      def initialize io
        @io = io
        @i = 0
      end

      def next_statement
        append "\n"
        self
      end

      def statement statement
        indent
        @io << statement
        next_statement
        self
      end

      def begin_module name
        statement "module #{name}"
        inc_indent
        self
      end

      def begin_class name
        statement "class #{name}"
        inc_indent
        self
      end

      def begin_def name, args = []
        statement method_definition(name, args)
        inc_indent
        self
      end

      def end
        dec_indent
        statement "end"
        self
      end

      private
      def method_definition name, args
        s = "def #{name}"
        s << "(#{args * ', '})" unless args.empty?
        s
      end

      def append str
        @io << str
      end

      def indent
        @io << "  " * @i
      end

      def inc_indent n = 1
        @i += n
      end

      def dec_indent n = 1
        @i -= n
      end
    end
  end
end
