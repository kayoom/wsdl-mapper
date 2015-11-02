require 'wsdl_mapper/naming/default_namer'
require 'wsdl_mapper/generation/result'
require 'wsdl_mapper/generation/default_formatter'
require 'wsdl_mapper/generation/type_to_generate'
require 'wsdl_mapper/dom/complex_type'
require 'wsdl_mapper/dom/simple_type'

module WsdlMapper
  module S8rGeneration
    class Generator
      include WsdlMapper::Generation

      def initialize context, namer: WsdlMapper::Naming::DefaultNamer.new, formatter_factory: DefaultFormatter
        @context = context
        @namer = namer
        @formatter_factory = formatter_factory
      end

      def generate schema
        result = Result.new schema

        schema.each_type do |type|
          generate_type type, result
        end
      end

      def generate_type type, result
        name = @namer.get_s8r_name type
        file_name = @context.path_for name

        File.open file_name, 'w' do |io|
          f = get_formatter io
          ttg = TypeToGenerate.new type, name

          open_class f, ttg
          # def_ctr f, ttg
          def_build_method f, ttg

          # props = type.each_property
          # props.each do |prop|
          #   prop_name = @namer.get_property_name prop
          #   ptg = TypeToGenerate.new prop, prop_name
          #   def_prop f, ptg
          # end

          close_class f, ttg
        end
      end

      def get_formatter io
        @formatter_factory.new io
      end

      protected
      # def def_prop f, ptg
      #   f.begin_def ptg.name.attr_name
      #   f.statement "@tm.to_ruby(::WsdlMapper::Dom::BuiltinType[#{ptg.type.type_name.name.inspect}], @obj.#{ptg.name.attr_name})"
      #   f.end
      # end

      # def def_ctr f, ttg
      #   f.begin_def "initialize", [:base]
      #   f.assignment ["@base", "base"]
      #   f.end
      # end

      def def_simple_build_method_body f, ttg
        tag = tag_string_for_name ttg.type.name
        f.block "x.simple(#{tag})", ["x"] do
          root_type = ttg.type.root.name.name
          f.statement "x.text_builtin(obj, #{root_type.inspect})"
        end
      end

      def def_complex_build_method_body f, ttg
        tag = tag_string_for_name ttg.type.name
        f.block "x.complex(#{tag})", ["x"] do
          ttg.type.each_property do |prop|
            write_property_statement f, prop
          end
        end
      end

      def write_property_statement f, prop
        case prop.type
        when ::WsdlMapper::Dom::BuiltinType
          write_builtin_property_statement f, prop
        when ::WsdlMapper::Dom::ComplexType
          write_complex_property_statement f, prop
        when ::WsdlMapper::Dom::SimpleType
          write_simple_property_statement f, prop
        end
      end

      def write_simple_property_statement f, prop
        s8r_name = @namer.get_s8r_name prop.type
        name = @namer.get_property_name(prop).attr_name
        f.statement "x.get(#{s8r_name.require_path.inspect}).build(x, obj.#{name})"
      end

      def write_complex_property_statement f, prop
        s8r_name = @namer.get_s8r_name prop.type
        name = @namer.get_property_name(prop).attr_name
        f.statement "x.get(#{s8r_name.require_path.inspect}).build(x, obj.#{name})"
      end

      def write_builtin_property_statement f, prop
        tag = tag_string_for_name prop.name
        name = @namer.get_property_name(prop).attr_name
        type = prop.type_name.name.inspect
        f.statement "x.value_builtin(#{tag}, obj.#{name}, #{type})"
      end

      def def_build_method f, ttg
        f.begin_def "build", [:x, :obj]
        case ttg.type
        when ::WsdlMapper::Dom::ComplexType
          def_complex_build_method_body f, ttg
        when ::WsdlMapper::Dom::SimpleType
          def_simple_build_method_body f, ttg
        end
        f.end
      end

      def close_class f, ttg
        f.end
      end

      def open_class f, ttg
        f.begin_class ttg.name.class_name
      end

      def tag_for_name name
        # TODO: respect namespaces
        name.name
      end

      def tag_string_for_name name
        tag_for_name(name).inspect
      end
    end
  end
end
