module WsdlMapper
  module DomGeneration
    # @abstract
    class GeneratorBase
      def initialize generator
        @generator = generator
      end

      protected
      def add_type_require requires, type_name, schema
        if WsdlMapper::Dom::BuiltinType.builtin? type_name
          @generator.type_mapping.requires(type_name).each do |req|
            requires << req
          end
        else
          type = schema.get_type type_name
          name = @generator.namer.get_type_name type
          requires << name.require_path
        end
      end

      def add_base_require requires, type, schema
        if type.base_type_name && @generator.get_ruby_type_name(type.base)
          add_type_require requires, type.base_type_name, schema
        end
      end

      def write_requires f, requires
        f.requires *requires
      end

      def close_modules f, modules
        modules.each { f.end }
      end

      def open_modules f, modules
        modules.each do |mod|
          f.begin_module mod.module_name
        end
      end
    end
  end
end
