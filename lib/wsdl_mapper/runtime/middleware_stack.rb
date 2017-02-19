module WsdlMapper
  module Runtime
    class MiddlewareStack
      include Enumerable

      class Item < Struct.new(:name, :middleware)
      end
      private_constant :Item

      def initialize
        @stack = []
      end

      # Clears the stack.
      def clear
        @stack = []
      end

      # @return [Array<String>] The names of the middlewares in order.
      def names
        @stack.map &:name
      end

      # @param [String] name
      def remove(name)
        @stack.delete_if { |item| item.name == name }
      end

      # @param [String] name The name of the middleware item to replace
      # @param [Object, Proc] middleware The new middleware
      def replace(name, middleware)
        @stack[get_position(name)] = Item.new name, middleware
        middleware
      end
      alias_method :[]=, :replace

      # @param [String] name
      # @return [Object, Proc] The middleware for `name`.
      # @raise [ArgumentError] if there is no middleware with this `name`.
      def get(name)
        @stack[get_position(name)].middleware
      end
      alias_method :[], :get

      # Appends the given `middleware` to the stack.
      # @param [String] name
      # @param [Object, Proc] middleware
      def add(name, middleware)
        @stack << Item.new(name, middleware)
        middleware
      end
      alias_method :append, :add

      # Prepends the given `middleware`.
      # @param [String] name
      # @param [Object, Proc] middleware
      def prepend(name, middleware)
        @stack.unshift Item.new(name, middleware)
      end

      # Inserts the given `middleware` **after** the middleware named `target`.
      # @param [String] target
      # @param [String] name
      # @param [Object, Proc] middleware
      # @raise [ArgumentError] if there is no middleware with named `target`.
      def after(target, name, middleware)
        @stack.insert get_position(target) + 1, Item.new(name, middleware)
      end

      # Inserts the given `middleware` **before** the middleware named `target`.
      # @param [String] target
      # @param [String] name
      # @param [Object, Proc] middleware
      # @raise [ArgumentError] if there is no middleware with named `target`.
      def before(target, name, middleware)
        @stack.insert get_position(target), Item.new(name, middleware)
      end

      # Enumerates all middlewares in order
      # @yieldparam middleware [Object, Proc]
      # @return [Enumerator]
      def each(&block)
        @stack.lazy.map(&:middleware).each &block
      end

      # Calls each middleware in order, by passing the output from the last middleware
      # to the next.
      # @param [Array] inputs Input to the first middleware on the stack
      # @return [Object] The output of the last middleware on the stack
      def execute(inputs)
        inject(inputs) do |obj, middleware|
          middleware.call(*obj)
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
