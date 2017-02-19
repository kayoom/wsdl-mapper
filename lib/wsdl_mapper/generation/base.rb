require 'logging'

module WsdlMapper
  module Generation
    # @abstract
    class Base
      attr_reader :logger
      protected :logger

      def initialize(context)
        @context = context
        @logger = Logging.logger[self]
      end

      def generate_name(name, suffix = '')
        return 'nil' if name.nil?

        ns = name.ns.inspect
        local_name = (name.name + suffix).inspect


        "[#{ns}, #{local_name}]"
      end

      def get_type_name(type)
        if type.name
          type
        elsif type.containing_element
          @namer.get_inline_type type.containing_element
        elsif type.containing_property
          @namer.get_inline_type type.containing_property
        end
      end

      def file_for(type_name, result, &block)
        file_name = @context.path_for type_name
        file file_name, result, &block
      end

      def append_file_for(type_name, result, &block)
        file_name = @context.path_for type_name
        file file_name, result, mode: 'a', &block
      end

      # @yieldparam [WsdlMapper::Generation::AbstractFormatter]
      def type_file_for(type_name, result, &block)
        file_for type_name, result, &block
        result.add_type type_name
      end

      def file(file_name, result, mode: 'w')
        File.open file_name, mode do |io|
          f = get_formatter io
          yield f
        end

        result.files << file_name
      end

      def get_formatter(io)
        @formatter_factory.new io
      end

      def get_module_names(type)
        type.parents.reverse.map(&:module_name)
      end
    end
  end
end
