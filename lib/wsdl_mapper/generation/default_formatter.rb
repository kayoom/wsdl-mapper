require 'wsdl_mapper/generation/abstract_formatter'

module WsdlMapper
  module Generation
    # Default implementation for the ruby formatter interface. This class should be considered as a reference for
    # custom implementations. All public methods are mandatory.
    class DefaultFormatter < AbstractFormatter
      def initialize io
        super
        @i = 0
      end

      def next_statement
        append "\n"
      end
      alias_method :blank_line, :next_statement
      alias_method :after_requires, :next_statement
      alias_method :after_constants, :next_statement

      def statement statement
        indent
        @io << statement
        next_statement
      end

      def require path
        # TODO: escape
        statement %[require #{path.inspect}]
      end

      def attr_accessor *attrs
        return if attrs.empty?
        # TODO: check/escape
        attrs = attrs.map { |a| ":#{a}" }
        attrs.each do |attr|
          statement "attr_accessor #{attr}"
        end
      end

      def begin_module name
        statement "module #{name}"
        inc_indent
      end

      def begin_class name
        statement "class #{name}"
        inc_indent
      end

      def begin_sub_class name, super_name
        statement "class #{name} < #{super_name}"
        inc_indent
      end

      def begin_def name, args = []
        next_statement
        statement method_definition(name, args)
        inc_indent
      end

      def literal_array values
        statement "Values = ["
        inc_indent
        values[0..-2].each do |value|
          statement "#{value},"
        end
        statement values.last
        dec_indent
        statement "]"
      end

      def assignment *assigns
        assigns.each do |(var_name, value)|
          statement "#{var_name} = #{value}"
        end
      end

      def end
        dec_indent
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
