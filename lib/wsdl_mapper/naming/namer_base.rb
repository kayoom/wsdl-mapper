require 'wsdl_mapper/naming/type_name'
require 'wsdl_mapper/naming/inflector'

module WsdlMapper
  module Naming
    class NamerBase
      include Inflector

      KEYWORDS = %w[
        alias
        and
        begin
        break
        case
        catch
        class
        def
        do
        elsif
        else
        fail
        ensure
        for
        end
        if
        in
        module
        next
        not
        or
        raise
        redo
        rescue
        retry
        return
        then
        throw
        super
        unless
        undef
        until
        when
        while
        yield
        true
        false
        nil
        self
      ]

      attr_reader :module_path

      def initialize(module_path: [])
        @module_path = module_path
      end

      protected
      def make_parents(path)
        return if path.empty?
        mod, path = path.last, path[0...-1]
        type_name = TypeName.new mod, path, get_file_name(mod), get_file_path(path)
        type_name.parent = make_parents path
        type_name
      end

      def get_constant_name(name)
        get_key_name(name).upcase
      end

      def get_key_name(name)
        underscore sanitize name
      end

      def get_accessor_name(name)
        get_key_name name
      end

      def get_var_name(name)
        "@#{get_accessor_name(name)}"
      end

      def get_file_name(name)
        underscore(name) + '.rb'
      end

      def get_file_path(path)
        path.map do |m|
          underscore m
        end
      end

      def sanitize(name)
        if valid_symbol? name
          name
        else
          "x_#{name}"
        end
      end

      def valid_symbol?(name)
        name =~ /^[a-zA-Z]/ && !KEYWORDS.include?(name.to_s)
      end
    end
  end
end

