module WsdlMapper
  module Generation
    # Default implementation for the ruby formatter interface. This class should be considered as a reference for
    # custom implementations. All public methods are mandatory.
    class DefaultFormatter
      def initialize io
        @io = io
        @i = 0
      end

      def next_statement
        append "\n"
        @blank_line = false
        self
      end

      def blank_line
        # Prevent double blank lines
        append "\n" unless @blank_line
        @blank_line = true
        self
      end

      def blank_comment
        statement '#'
        @blank_line = true
        self
      end

      def attr_readers *attrs
        return if attrs.empty?

        attrs = attrs.map { |a| ":#{a}" }
        attrs.each do |attr|
          statement "attr_reader #{attr}"
        end
        blank_line
      end

      alias_method :after_requires, :blank_line
      alias_method :after_constants, :blank_line

      def statement statement
        indent
        @io << statement
        next_statement
      end

      def statements *statements
        statements.each do |s|
          statement s
        end
        blank_line
      end

      def call name, *args
        statement "#{name}(#{args * ', '})"
      end

      def block statement, block_args
        indent
        buf = statement.dup
        buf << ' do'
        args = block_args.join ', '
        buf << " |#{args}|" if block_args.any?
        @io << buf
        next_statement
        inc_indent
        yield
        self.end
      end

      def block_assignment var_name, statement, block_args, &block
        block "#{var_name} = #{statement}", block_args, &block
      end

      def require path
        statement "require #{path.inspect}"
      end

      def requires *paths
        return unless paths.any?
        paths.each do |path|
          require path
        end
        after_requires
      end

      def attr_accessors *attrs
        return if attrs.empty?

        attrs = attrs.map { |a| ":#{a}" }
        attrs.each do |attr|
          statement "attr_accessor #{attr}"
        end
        blank_line
      end

      def begin_module name
        statement "module #{name}"
        inc_indent
      end

      def begin_modules names
        names.each do |name|
          begin_module name
        end
      end

      def end_modules names
        names.each { self.end }
      end

      def in_modules names
        begin_modules names
        yield
        end_modules names
      end

      def begin_class name
        statement "class #{name}"
        inc_indent
      end

      def begin_sub_class name, super_name
        statement "class #{name} < #{super_name}"
        inc_indent
      end

      def in_class name
        begin_class name
        yield
        self.end
      end

      def in_sub_class name, super_name
        begin_sub_class name, super_name
        yield
        self.end
      end

      def begin_def name, *args
        blank_line
        statement method_definition(name, args)
        inc_indent
      end

      def in_def name, *args
        begin_def name, *args
        yield
        self.end
      end

      def literal_array name, values
        if values.empty?
          statement "#{name} = []"
          return
        end

        statement "#{name} = ["
        inc_indent
        values[0..-2].each do |value|
          statement "#{value},"
        end
        statement values.last
        dec_indent
        statement "]"
      end

      def assignment var_name, value
        statement "#{var_name} = #{value}"
      end

      def assignments *assigns
        assigns.each do |(var_name, value)|
          assignment var_name, value
        end
        blank_line
      end

      def end
        dec_indent
        if @blank_line
          @io.seek -1, IO::SEEK_CUR
        end
        statement "end"
      end

      private
      def method_definition name, args
        s = "def #{name}"
        s << "(#{args * ', '})" unless args.empty?
        s
      end

      def append str
        @io << str
        self
      end

      def indent
        @io << "  " * @i
        self
      end

      def inc_indent n = 1
        @i += n
        self
      end

      def dec_indent n = 1
        @i -= n
        self
      end
    end
  end
end
