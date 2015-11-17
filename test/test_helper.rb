require 'bundler/setup'

if ENV['cov']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'abstract_.*\.rb'
  end
end

require 'minitest/autorun'
require 'minitest/focus'

require 'nokogiri'

require 'byebug'

require 'wsdl_mapper/dom_parsing/default_resolver'

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
    import_resolver ||= ::WsdlMapper::DomParsing::DefaultResolver.new File.join("test", "fixtures")
    WsdlMapper::DomParsing::Parser.new(import_resolver: import_resolver).parse get_xml_doc name
  end

  def parse_wsdl name
    WsdlMapper::SvcDescParsing::Parser.new.parse get_xml_doc name
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

class SchemaTestCase < Minitest::Test
  def get_schema name
    TestHelper.parse_schema name
  end
end

class GenerationTestCase < SchemaTestCase
  def setup
    @tmp_path = TestHelper.get_tmp_path
  end

  def teardown
    @tmp_path.unlink
  end

  def tmp_path
    @tmp_path
  end

  def path_for *name
    tmp_path.join *name
  end

  def assert_file_exists *name
    path = tmp_path.join *name
    assert File.exist?(path), "Expected file #{name * '/'} to exist."
  end

  def assert_file_is *name, expected
    assert_file_exists *name
    assert_equal expected, file(*name)
  end

  def file *name
    File.read tmp_path.join *name
  end

  def context
    @context ||= WsdlMapper::Generation::Context.new @tmp_path.to_s
  end
end
