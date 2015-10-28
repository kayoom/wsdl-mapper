module WsdlMapper
  module Generation
    class YardDocFormatter
      def initialize formatter
        @formatter = formatter
        @i = 0
      end

      def line line
        buf = "# "
        buf << "  " * @i
        buf << strip(line)
        @formatter.statement buf
        self
      end

      def inc_indent
        @i += 1
        self
      end

      def dec_indent
        @i -= 1
        self
      end

      def text text
        lines = text.split("\n")

        lines.each do |l|
          line l
        end
        self
      end

      def blank_line
        @formatter.statement "#"
        self
      end

      def tag tag, text
        line "@#{tag} #{text}"
        self
      end

      def type_tag tag, type, text
        line "@#{tag} [#{type}] #{text}"
        self
      end

      def attribute! name, type, text, &block
        tag "!attribute", name
        inc_indent
        type_tag "return", type, strip(text)
        block.call
        dec_indent
        self
      end

      protected
      def strip text
        return "" if text.nil?
        text.gsub(/[\n\r]/, " ").gsub(/\s+/, " ").strip
      end
    end
  end
end
