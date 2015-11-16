module WsdlMapper
  module Parsing
    module Logging

      class LogMsg
        def initialize node, source, msg = ''
          @node = node
          @source = source
          @node_name = node && node.name
          @msg = msg
        end

        def to_s
          "#{@msg}: #{@node} - #{@source.class.name}"
        end
      end

      attr_accessor :log_msgs

      # @param [Nokogiri::XML::Node] node
      # @param [String, Symbol] msg
      def log_msg node, msg = '', source = self
        @log_msgs ||= []
        @log_msgs << LogMsg.new(node, source, msg)
        # TODO: remove debugging output
        puts node.to_s
        puts msg
        puts caller
        puts "\n\n"
      end
    end
  end
end
