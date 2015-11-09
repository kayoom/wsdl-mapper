require 'wsdl_mapper/dom/name'

module WsdlMapper
  module Dom
    class Directory
      include Enumerable

      def initialize &block
        if block
          @data = Hash.new do |h, k|
            h[k] = Hash.new do |h2, k2|
              h2[k2] = block[k, k2]
            end
          end
        else
          @data = {}
        end
      end

      def get name
        hsh = @data[name.ns]
        hsh ? hsh[name.name] : nil
      end
      alias_method :[], :get

      def set name, value
        @data[name.ns] ||= {}
        @data[name.ns][name.name] = value
      end
      alias_method :[]=, :set

      def each &block
        enum = Enumerator.new do |y|
          @data.each do |ns, data|
            data.each do |name, value|
              y << [WsdlMapper::Dom::Name.get(ns, name), value]
            end
          end
        end
        block_given? ? enum.each(&block) : enum.each
      end
    end
  end
end
