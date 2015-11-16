require 'wsdl_mapper/deserializers/frame'

module WsdlMapper
  module Deserializers
    class SaxDocument < ::Nokogiri::XML::SAX::Document
      include WsdlMapper::Dom

      attr_reader :object

      def initialize base
        @base = base
      end

      def start_element_namespace name, attrs = [], prefix = nil, uri = nil, ns = []
        @buffer = ""
        uri = inherit_element_namespace uri
        name = Name.get uri, name
        namespaces = Namespaces.for Hash[ns]
        type_name = get_type_name name
        attrs = get_attributes type_name, attrs
        @current_frame = Frame.new name, type_name, attrs, @current_frame, namespaces, @base
        @current_frame.start
      end

      def end_element_namespace name, prefix = nil, uri = nil
        @current_frame.text = @buffer
        @buffer = ""
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

      def characters text
        @buffer << text
      end

      protected
      def get_type_name name
        if @current_frame
          # TODO: xsi:type
          @current_frame.mapping.get_type name
        else
          # root element -> (tag-)name == type name
          # TODO: thats wrong
          name
        end
      end

      def inherit_element_namespace ns
        if ns.nil? && !@base.qualified_elements? && @current_frame
          @current_frame.type_name.ns
        else
          ns
        end
      end

      def inherit_attr_namespace type_name, ns
        if ns.nil? && !@base.qualified_attributes? && @current_frame
          type_name.ns
        else
          ns
        end
      end

      def get_attributes type_name, attrs
        attrs.map do |attr|
          uri = inherit_attr_namespace type_name, attr.uri
          name = Name.get uri, attr.localname
          [name, attr.value]
        end
      end

      # TODO: cdata?
    end
  end
end
