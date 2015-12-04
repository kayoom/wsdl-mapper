require 'wsdl_mapper/generation/base'
require 'wsdl_mapper/generation/type_to_generate'

require 'wsdl_mapper/generation/default_formatter'
require 'wsdl_mapper/generation/result'
require 'wsdl_mapper/naming/type_name'
require 'wsdl_mapper/naming/default_service_namer'
require 'wsdl_mapper/naming/default_namer'

require 'wsdl_mapper/dom_parsing/parser'
require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/default_ctr_generator'

require 'wsdl_mapper/svc_generation/type_to_generate'
require 'wsdl_mapper/svc_generation/service_generator'
require 'wsdl_mapper/svc_generation/port_generator'
require 'wsdl_mapper/svc_generation/operation_generator'
require 'wsdl_mapper/svc_generation/operation_s8r_generator'
require 'wsdl_mapper/svc_generation/operation_d10r_generator'

module WsdlMapper
  module SvcGeneration
    class SvcGenerator < WsdlMapper::Generation::Base
      include WsdlMapper::Generation

      attr_reader :context, :service_generator, :service_namer, :namer, :port_generator, :operation_generator, :schema_generator, :operation_s8r_generator, :operation_d10r_generator

      def initialize context,
          formatter_factory: DefaultFormatter,
          service_namer: WsdlMapper::Naming::DefaultServiceNamer.new,
          namer: WsdlMapper::Naming::DefaultNamer.new,
          service_generator_factory: ServiceGenerator,
          port_generator_factory: PortGenerator,
          operation_generator_factory: OperationGenerator,
          operation_s8r_generator_factory: OperationS8rGenerator,
          operation_d10r_generator_factory: OperationD10rGenerator,
          schema_generator: nil
        @formatter_factory = formatter_factory
        @context = context
        @service_namer = service_namer
        @namer = namer
        @service_generator = service_generator_factory.new(self)
        @port_generator = port_generator_factory.new(self)
        @operation_generator = operation_generator_factory.new(self)
        @operation_s8r_generator = operation_s8r_generator_factory.new(self)
        @operation_d10r_generator = operation_d10r_generator_factory.new(self)
        @schema_generator = schema_generator || WsdlMapper::DomGeneration::SchemaGenerator.new(context,
          ctr_generator_factory: WsdlMapper::DomGeneration::DefaultCtrGenerator,
          namer: namer
        )
      end

      def generate desc
        result = Result.new description: desc

        generate_api desc, result

        result
      end

      def get_formatter io
        @formatter_factory.new io
      end

      def generate_api desc, result
        name = @service_namer.get_api_name
        modules = get_module_names name
        services = desc.each_service.map do |service|
          TypeToGenerate.new service, @service_namer.get_service_name(service), @service_namer.get_property_name(service)
        end

        services.each do |service|
          @service_generator.generate_service service, result
        end

        type_file_for name, result do |f|
          f.requires api_base.require_path
          f.requires *services.map { |s| s.name.require_path }

          f.in_modules modules do
            generate_api_class f, name, services
          end
        end
      end

      def generate_api_class f, name, services
        f.in_sub_class name.class_name, api_base.name do
          generate_api_service_accessors f, services
          generate_api_ctr f, services
        end
      end

      def generate_api_service_accessors f, services
        f.attr_readers *services.map { |s| s.property_name.attr_name }
      end

      def generate_api_ctr f, services
        f.in_def :initialize, 'options = {}' do
          f.call :super, 'options'
          services.each do |s|
            f.assignment s.property_name.var_name, "#{s.name.name}.new(self)"
            f.statement "@_services << #{s.property_name.var_name}"
          end
        end
      end

      def in_classes f, *names, &block
        next_block = if names.length > 1
          proc do
            in_classes f, *names.drop(1), &block
          end
        else
          block
        end
        f.in_class names.first, &next_block
      end

      def api_base
        @api_base ||= runtime_base 'Api', 'api'
      end

      def service_base
        @service_base ||= runtime_base 'Service', 'service'
      end

      def port_base
        @port_base ||= runtime_base 'Port', 'port'
      end

      def operation_base
        @operation_base ||= runtime_base 'Operation', 'operation'
      end

      def header_base
        @header_base ||= runtime_base 'Header', 'header'
      end

      def body_base
        @body_base ||= runtime_base 'Body', 'body'
      end

      def runtime_base name, file_name
        WsdlMapper::Naming::TypeName.new name, runtime_modules, "#{file_name}.rb", runtime_path
      end

      def runtime_modules
        @runtime_modules ||= %w[WsdlMapper Runtime]
      end

      def runtime_path
        @runtime_path ||= %w[wsdl_mapper runtime]
      end

      def get_type_name type
        @schema_generator.get_type_name type
      end
    end
  end
end
