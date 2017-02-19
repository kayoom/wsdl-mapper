module WsdlMapper
  module Naming
    # Module with inflection helper methods. As a permanent dependency on Rails'
    # ActiveSupport library is not feasible, here are some quick re-implementations.
    module Inflector
      extend self

      FIRST_CHAR = /^./
      NON_WORD = /[^a-zA-Z]/
      NON_AN = /[^a-zA-Z0-9]/
      NON_WORD_FOLLOWED_BY_WORD = /[^a-zA-Z0-9]+([a-zA-Z0-9])/
      CAPITALS = /([A-Z])/
      DOWN_FOLLOWED_BY_UP = /([a-z0-9])([A-Z])/

      # Camelize a string.
      # @param [String] source String to camelize.
      # @return [String] Camelized string.
      # @example
      #   camelize('foo_bar baz ') #=> 'FooBarBaz'
      def camelize(source)
        source.
          strip.
          gsub(NON_WORD_FOLLOWED_BY_WORD) { |s| $1.upcase }.
          sub(FIRST_CHAR) { |s| s.upcase }
      end

      # Snake-cases a string.
      # @param [String] source String to underscore.
      # @return [String] snake-cased string.
      # @example
      #   underscore('Foo Bar') #=> 'foo_bar'
      def underscore(source)
        source.
          strip.
          gsub(DOWN_FOLLOWED_BY_UP) { |s| "#{$1}_#{$2.downcase}" }.
          downcase.
          gsub(NON_AN, '_').
          gsub(/_+/, '_')
      end
    end
  end
end
