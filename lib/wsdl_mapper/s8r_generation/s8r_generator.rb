require 'wsdl_mapper/naming/default_namer'
require 'wsdl_mapper/generation/result'
require 'wsdl_mapper/generation/default_formatter'
require 'wsdl_mapper/generation/type_to_generate'
require 'wsdl_mapper/dom/complex_type'
require 'wsdl_mapper/dom/simple_type'

module WsdlMapper
  module S8rGeneration
    class S8rGenerator
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
          def_build_method f, ttg
          close_class f, ttg
        end
      end

      def get_formatter io
        @formatter_factory.new io
      end

      protected
      def def_simple_build_method_body f, ttg
        ns = ttg.type.name.ns.inspect
        tag = tag_string_for_name ttg.type.name
        f.block "x.simple(#{ns}, #{tag})", ["x"] do
          root_type = ttg.type.root.name.name
          f.statement "x.text_builtin(obj, #{root_type.inspect})"
        end
      end

      def def_complex_build_method_body f, ttg
        f.literal_array "attributes", collect_attributes(ttg)
        ns = ttg.type.name.ns.inspect
        tag = tag_string_for_name ttg.type.name
        f.block "x.complex(#{ns}, #{tag}, attributes)", ["x"] do
          if ttg.type.simple_content?
            write_content_statement f, ttg
          elsif ttg.type.soap_array?
            write_soap_array_statements f, ttg
          else
            write_property_statements f, ttg
          end
        end
      end

      def write_content_statement f, ttg
        content_name = @namer.get_content_name ttg.type
        type = ttg.type.base.name.name
        f.statement "x.text_builtin(obj.#{content_name.attr_name}, #{type.inspect})"
      end

      def write_property_statements f, ttg
        ttg.type.each_property do |prop|
          write_property_statement f, prop
        end
      end

      def collect_attributes ttg
        if ttg.type.soap_array?
          soap_array_attributes(ttg)
        else
          ttg.type.each_attribute.map do |attr|
            name = attr.name
            attr_name = @namer.get_attribute_name(attr).attr_name
            type = attr.type.root.name.name

            %<[nil, #{name.inspect}, obj.#{attr_name}, #{type.inspect}]>
          end
        end
      end

      def write_soap_array_statements f, ttg
        s8r_name = @namer.get_s8r_name ttg.type.soap_array_type
        f.block "obj.each", ["itm"] do
          f.statement "x.get(#{s8r_name.require_path.inspect}).build(x, itm)"
        end
      end

      def soap_array_attributes ttg
        # Use String#inspect to get the proper escaping, but cut off the last quotemark and append the array length
        name = ttg.type.soap_array_type_name.name.inspect[0..-2] + "[\#{obj.length}]\""
        [
          %<[x.soap_enc, "arrayType", #{name}, "string"]>
        ]
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
        ns = prop.name.ns.inspect
        type = prop.type_name.name.inspect
        f.statement "x.value_builtin(#{ns}, #{tag}, obj.#{name}, #{type})"
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
        name.name
      end

      def tag_string_for_name name
        tag_for_name(name).inspect
      end
    end
  end
end
