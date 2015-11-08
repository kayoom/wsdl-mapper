require 'bundler/setup'

require 'simplecov'
SimpleCov.start do
  add_filter 'abstract_.*\.rb'
end

require 'minitest/autorun'

require 'nokogiri'

require 'byebug'

require 'wsdl_mapper/schema/default_resolver'

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
    import_resolver ||= ::WsdlMapper::Schema::DefaultResolver.new File.join("test", "fixtures")
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
    assert File.exist? tmp_path.join *name
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
