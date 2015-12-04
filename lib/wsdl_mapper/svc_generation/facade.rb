require 'wsdl_mapper/generation/facade'
require 'wsdl_mapper/svc_desc_parsing/parser'
require 'wsdl_mapper/naming/default_service_namer'
require 'wsdl_mapper/svc_generation/svc_generator'
require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/documented_schema_generator'
require 'wsdl_mapper/s8r_generation/s8r_generator'
require 'wsdl_mapper/d10r_generation/d10r_generator'

module WsdlMapper
  module SvcGeneration
    class Facade < WsdlMapper::Generation::Facade

      def service_namer
        @service_namer ||= WsdlMapper::Naming::DefaultServiceNamer.new(module_path: @module_path)
      end

      def schema_generator
        @schema_generator ||= schema_generator_class.new context, namer: namer, ctr_generator_factory: WsdlMapper::DomGeneration::DefaultCtrGenerator
      end

      def schema_generator_class
        @schema_generator_class ||= @docs ? WsdlMapper::DomGeneration::DocumentedSchemaGenerator : WsdlMapper::DomGeneration::SchemaGenerator
      end

      def s8r_generator
        @s8r_generator ||= WsdlMapper::S8rGeneration::S8rGenerator.new context, namer: namer
      end

      def d10r_generator
        @d10r_generator ||= WsdlMapper::D10rGeneration::D10rGenerator.new context, namer: namer
      end

      def svc_generator
        @svc_generator ||= WsdlMapper::SvcGeneration::SvcGenerator.new context, namer: namer, service_namer: service_namer, schema_generator: schema_generator
      end

      def generate
        desc, schema = parser.parse document

        schema_generator.generate schema
        s8r_generator.generate schema
        d10r_generator.generate schema
        svc_generator.generate desc
      end

      def parser
        @parser ||= WsdlMapper::SvcDescParsing::Parser.new
      end
    end
  end
end
