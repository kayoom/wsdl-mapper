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

      def remove(name)
        @stack.delete_if { |item| item.name == name }
      end

      def replace(name, middleware)
        index = @stack.index { |item| item.name == name }
        @stack[index] = Item.new name, middleware
      end

      def add(name, middleware)
        @stack << Item.new(name, middleware)
      end
      alias_method :append, :add
      alias_method :<<, :add

      def prepend(name, middleware)
        @stack.unshift Item.new(name, middleware)
      end

      def after(target, name, middleware)
        index = @stack.index { |item| item.name == target }
        raise ArgumentError.new("#{target} not found.") if index.nil?
        @stack.insert index + 1, Item.new(name, middleware)
      end

      def before(target, name, middleware)
        index = @stack.index { |item| item.name == target }
        raise ArgumentError.new("#{target} not found.") if index.nil?
        @stack.insert index, Item.new(name, middleware)
      end

      def each &block
        @stack.lazy.map(&:middleware).each &block
      end
    end
  end
end
