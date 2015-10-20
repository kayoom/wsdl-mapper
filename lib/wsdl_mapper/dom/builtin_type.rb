require 'wsdl_mapper/dom/type_base'

module WsdlMapper
  module Dom
    class BuiltinType < TypeBase
      NAMESPACE = "http://www.w3.org/2001/XMLSchema".freeze

      # INT_TYPES = %w[
      #   byte
      #   int
      #   integer
      #   long
      #   negativeInteger
      #   nonNegativeInteger
      #   nonPositiveInteger
      #   positiveInteger
      #   short
      #   unsignedLong
      #   unsignedInt
      #   unsignedShort
      #   unsignedByte
      # ]
      #
      # STRING_TYPES = %w[
      #   ENTITIES
      #   ENTITY
      #   ID
      #   IDREF
      #   IDREFS
      #   language
      #   Name
      #   NCName
      #   NMTOKEN
      #   NMTOKENS
      #   normalizedString
      #   QName
      #   string
      #   token
      # ]
      #
      # DECIMAL_TYPES = %w[
      #   decimal
      # ]
      #
      # DATE_TIME_TYPES = %w[
      #   date
      #   dateTime
      # ]
      #
      # DURATION_TYPES = %w[
      #   time
      #   duration
      # ]

      def self.types
        @types ||= Hash.new do |h, k|
          h[k] = build k
        end
      end

      def self.[] name
        types[name.to_s]
      end

      def self.build name
        new Name.new(NAMESPACE, name.to_s)
      end

      extend Enumerable

      def self.each &block
        types.values.each &block
      end

      def self.builtin? name
        return name.ns == NAMESPACE
      end

      # def self.int? name
      #   return false unless name.ns == NAMESPACE
      #
      #   INT_TYPES.include? name.name
      # end
      #
      # def self.string? name
      #   return false unless name.ns == NAMESPACE
      #
      #   STRING_TYPES.include? name.name
      # end
      #
      # def self.decimal? name
      #   return false unless name.ns == NAMESPACE
      #
      #   DECIMAL_TYPES.include? name.name
      # end
      #
      # def self.date_time? name
      #   return false unless name.ns == NAMESPACE
      #
      #   DATE_TIME_TYPES.include? name.name
      # end
      #
      # def self.duration? name
      #   return false unless name.ns == NAMESPACE
      #
      #   DURATION_TYPES.include? name.name
      # end
    end
  end
end
