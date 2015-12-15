module WsdlMapper
  module Runtime
    class MiddlewareStack
      include Enumerable

      class Item < Struct.new(:name, :middleware)
      end

      def initialize
        @stack = []
      end

      def clear
        @stack = []
      end

      def names
        @stack.map &:name
      end

      def remove(name)
        @stack.delete_if { |item| item.name == name }
      end

      def replace(name, middleware)
        @stack[get_position(name)] = Item.new name, middleware
        middleware
      end
      alias_method :[]=, :replace

      def get(name)
        @stack[get_position(name)].middleware
      end
      alias_method :[], :get

      def add(name, middleware)
        @stack << Item.new(name, middleware)
      end
      alias_method :append, :add

      def prepend(name, middleware)
        @stack.unshift Item.new(name, middleware)
      end

      def after(target, name, middleware)
        @stack.insert get_position(target) + 1, Item.new(name, middleware)
      end

      def before(target, name, middleware)
        @stack.insert get_position(target), Item.new(name, middleware)
      end

      def each(&block)
        @stack.lazy.map(&:middleware).each &block
      end

      def execute(input)
        inject(input) do |obj, middleware|
          middleware.call *obj
        end
      end

      private
      def get_position(name)
        index = @stack.index { |item| item.name == name }
        raise ArgumentError.new("#{name} not found.") if index.nil?
        index
      end
    end
  end
end
