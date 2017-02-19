require 'thor'

require 'wsdl_mapper/dom_generation/facade'
require 'wsdl_mapper/s8r_generation/facade'
require 'wsdl_mapper/d10r_generation/facade'
require 'wsdl_mapper/svc_generation/facade'

require 'logging'
Logging.logger.root.appenders = Logging.appenders.stdout

module WsdlMapper
  # @api cli
  module Cli
    class Generate < Thor
      class_option :out, desc: 'The output directory. If omitted, takes the <xsd_file> (without extension), e.g. `ebaySvc.xsd` => `ebaySvc`.'
      class_option :module, desc: 'The ruby root module, for the generated classes.'
      class_option :separate_modules, type: :boolean, default: true, desc: 'Set to <true> to separate types, serializers and deserializers into different modules and subdirectories.'
      class_option :clear, type: :boolean, default: true, desc: 'Set to <true> to clear out the ouput directory before generation.'
      class_option :docs, type: :boolean, default: true, desc: 'Set to <true> to generate yardoc annotations and (if present in xsd) doc strings for generated classes and attributes.'

      no_tasks do
        def facade_options(xsd_file, ext)
          {
            file: xsd_file,
            out: out(xsd_file, ext),
            module_path: module_path,
            docs: options[:docs],
            separate_modules: options[:separate_modules]
          }
        end

        def module_path
          options[:module] ? options[:module].split('::').compact : []
        end

        def out(xsd_file, ext)
          options[:out] || File.join(FileUtils.pwd, file_name(xsd_file, ext))
        end

        def file_name(xsd_file, ext)
          File.basename xsd_file, ext
        end
      end

      desc 'dom <xsd_file>', 'Generates classes for the schema in <xsd_file>'
      def dom(xsd_file)
        generator = WsdlMapper::DomGeneration::Facade.new(**facade_options(xsd_file, '.xsd'))
        FileUtils.rmtree out(xsd_file, '.xsd') if options[:clear]
        generator.generate
      end

      desc 's8r <xsd_file>', 'Generate serializers for the schema in <xsd_file>'
      def s8r(xsd_file)
        generator = WsdlMapper::S8rGeneration::Facade.new(**facade_options(xsd_file, '.xsd'))
        FileUtils.rmtree out(xsd_file, '.xsd') if options[:clear]
        generator.generate
      end

      desc 'd10r <xsd_file>', 'Generate deserializers for the schema in <xsd_file>'
      def d10r(xsd_file)
        generator = WsdlMapper::D10rGeneration::Facade.new(**facade_options(xsd_file, '.xsd'))
        FileUtils.rmtree out(xsd_file, '.xsd') if options[:clear]
        generator.generate
      end

      desc 'all <xsd_file>', 'Generate DOM, Serializers, Deserializers for the schema in <xsd_file>'
      def all(xsd_file)
        file_name = File.basename xsd_file, '.xsd'
        out = options[:out] || File.join(FileUtils.pwd, file_name)
        FileUtils.rmtree out if options[:clear]

        invoke :dom, [xsd_file], options.merge(clear: false)
        invoke :s8r, [xsd_file], options.merge(clear: false)
        invoke :d10r, [xsd_file], options.merge(clear: false)
      end

      desc 'svc <wsdl_file>', 'Generate SOAP client'
      def svc(wsdl_file)
        generator = WsdlMapper::SvcGeneration::Facade.new(**facade_options(wsdl_file, '.wsdl'))
        FileUtils.rmtree out(wsdl_file, '.wsdl') if options[:clear]
        generator.generate
      end
    end

    class Cli < Thor
      desc 'generate SUBCOMMAND ...ARGS', 'Generate DOM and/or (De)Serializers'
      subcommand 'generate', Generate
    end
  end
end
