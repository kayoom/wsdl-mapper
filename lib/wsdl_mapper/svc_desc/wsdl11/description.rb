require 'wsdl_mapper/dom/directory'

module WsdlMapper
  module SvcDesc
    module Wsdl11
      class Description
        include WsdlMapper::Dom

        attr_reader :name
        attr_accessor :target_namespace, :schema

        def initialize
          @name = nil
          @messages = Directory.new
          @port_types = Directory.new
          @bindings = Directory.new
          @services = Directory.new
        end

        def add_message message
          @messages[message.name] = message
        end

        def add_port_type port_type
          @port_types[port_type.name] = port_type
        end

        def add_service service
          @services[service.name] = service
        end

        def add_binding binding
          @bindings[binding.name] = binding
        end

        def each_message &block
          @messages.each_value &block
        end

        def each_port_type &block
          @port_types.each_value &block
        end

        def each_service &block
          @services.each_value &block
        end

        def each_binding &block
          @bindings.each_value &block
        end

        def get_message name
          @messages[name]
        end

        def get_port_type name
          @port_types[name]
        end

        def get_binding name
          @bindings[name]
        end

        def get_service name
          @services[name]
        end
      end
    end
  end
end
