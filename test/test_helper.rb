require 'bundler/setup'

require 'simplecov'
SimpleCov.start do
  add_filter 'abstract_.*\.rb'
end

require 'minitest/autorun'

require 'nokogiri'

require 'byebug'

require 'wsdl_mapper/schema/simple_import_resolver'

module TestHelper
  extend self

  def get_fixture(name)
    path = File.join "test", "fixtures", name
    File.read(path)
  end

  def get_xml_doc(name)
    Nokogiri::XML::Document.parse get_fixture name
  end

  def parse_schema(name, import_resolver: nil)
    import_resolver ||= ::WsdlMapper::Schema::SimpleImportResolver.new File.join("test", "fixtures")
    WsdlMapper::Schema::Parser.new(import_resolver: import_resolver).parse get_xml_doc name
  end

  class TmpPath
    def initialize
      @path = File.join File.dirname(__FILE__), 'tmp', SecureRandom.hex(5)
      FileUtils.mkdir_p @path
    end

    def join *args
      File.join @path, *args
    end

    def to_s
      @path
    end

    def unlink
      FileUtils.rm_rf @path
    end
  end

  def get_tmp_path
    TmpPath.new
  end
end
