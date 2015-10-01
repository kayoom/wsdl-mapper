module WsdlMapper
  module Naming
    module Inflector
      extend self

      FIRST_CHAR = /^./
      NON_WORD = /[^a-zA-Z]/
      NON_AN = /[^a-zA-Z0-9]/
      NON_WORD_FOLLOWED_BY_WORD = /[^a-zA-Z]+([a-zA-Z])/
      CAPITALS = /([A-Z])/
      DOWN_FOLLOWED_BY_UP = /([a-z])([A-Z])/

      def camelize source
        source.
          strip.
          gsub(NON_WORD_FOLLOWED_BY_WORD) { |s| $1.upcase }.
          sub(FIRST_CHAR) { |s| s.upcase }
      end

      def underscore source
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
