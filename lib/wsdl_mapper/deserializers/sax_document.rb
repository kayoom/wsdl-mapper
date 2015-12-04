require 'wsdl_mapper/deserializers/frame'

module WsdlMapper
  module Deserializers
    class SaxDocument < ::Nokogiri::XML::SAX::Document
      include WsdlMapper::Dom

      attr_reader :object

      # @param [WsdlMapper::Deserializers::Deserializer] base
      def initialize(base)
        @base = base
      end

      # @param [String] name
      # @param [Array<Nokogiri::XML::Attr>] attrs
      # @param [String] prefix
      # @param [String] uri
      # @param [Array<Array<String, String>] ns
      def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])
        @buffer = ''
        uri = inherit_element_namespace uri
        name = Name.get uri, name
        namespaces = Namespaces.for Hash[ns]
        if @current_frame && @current_frame.mapping.wrapper?(name)
          @wrapper = name
          return
        end
        type_name = get_type_name name
        attrs = get_attributes type_name, attrs
        parent = @current_frame
        mapping = @base.get_type_mapping type_name
        @current_frame = Frame.new name, type_name, attrs, parent, namespaces, @base, mapping
        @current_frame.start
      end

      # @param [String] name
      # @param [String] prefix
      # @param [String] uri
      def end_element_namespace(name, prefix = nil, uri = nil)
        if @wrapper == Name.get(uri, name)
          @wrapper = nil
          return
        end
        @current_frame.text = @buffer
        @buffer = ''
        @last_frame = @current_frame
        @current_frame = @current_frame.parent
        if @current_frame
          @current_frame.children << @last_frame
        end
        @last_frame.end
      end

      def end_document
        @object = @last_frame.object
      end

      def characters(text)
        @buffer << text
      end

      def cdata_block(text)
        @buffer << text
      end

      protected
      # @param [WsdlMapper::Dom::Name] element_name
      # @return [WsdlMapper::Dom::Name]
      def get_type_name(element_name)
        if @current_frame
          # TODO: xsi:type
          @current_frame.mapping.get_type_name_for_prop element_name
        else
          @base.get_element_type element_name
        end
      end

      def inherit_element_namespace(ns)
        # TODO: test
        if ns.nil? && !@base.qualified_elements? && @current_frame
          @current_frame.type_name.ns
        else
          ns
        end
      end

      def inherit_attr_namespace(type_name, ns)
        # TODO: test
        if ns.nil? && !@base.qualified_attributes? && @current_frame
          type_name.ns
        else
          ns
        end
      end

      def get_attributes(type_name, attrs)
        attrs.map do |attr|
          uri = inherit_attr_namespace type_name, attr.uri
          name = Name.get uri, attr.localname
          [name, attr.value]
        end
      end
    end
  end
end
