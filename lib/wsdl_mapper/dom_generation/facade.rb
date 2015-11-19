require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/documented_schema_generator'
require 'wsdl_mapper/generation/facade'
require 'wsdl_mapper/dom_generation/default_ctr_generator'

module WsdlMapper
  module DomGeneration
    class Facade < WsdlMapper::Generation::Facade
      def generator_class
        @generator_class ||= @docs ? DocumentedSchemaGenerator : SchemaGenerator
      end

      def generator
        @generator ||= generator_class.new context, namer: namer, ctr_generator_factory: WsdlMapper::DomGeneration::DefaultCtrGenerator
      end
    end
  end
end
