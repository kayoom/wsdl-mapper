require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/documented_wrapping_type_generator'
require 'wsdl_mapper/dom_generation/documented_class_generator'
require 'wsdl_mapper/dom_generation/documented_ctr_generator'
require 'wsdl_mapper/dom_generation/documented_enum_generator'

module WsdlMapper
  module DomGeneration
    class DocumentedSchemaGenerator < SchemaGenerator

      def initialize context,
          formatter_factory: DefaultFormatter,
          namer: WsdlMapper::Naming::DefaultNamer.new,
          class_generator_factory: DocumentedClassGenerator,
          module_generator_factory: DefaultModuleGenerator,
          ctr_generator_factory: DocumentedCtrGenerator,
          enum_generator_factory: DocumentedEnumGenerator,
          value_defaults_generator_factory: DefaultValueDefaultsGenerator,
          wrapping_type_generator_factory: DocumentedWrappingTypeGenerator,
          type_mapping: WsdlMapper::TypeMapping::DEFAULT,
          value_generator: DefaultValueGenerator.new

        super
      end

      def generate schema
        result = super

        generate_yard_opts

        result
      end

      protected
      def generate_yard_opts
        file_name = @context.path_join '.yardopts'

        File.write file_name, <<SH
--tag xml_name:"XML Name"
--tag xml_namespace:"XML Namespace"
--tag xml_value:"XML Value"
--markup markdown
--markup-provider redcarpet
**/*.rb
SH
      end
    end
  end
end
