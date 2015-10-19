require 'bundler/setup'

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'

require 'nokogiri'

require 'byebug'

module TestHelper
  extend self

  def get_fixture(name)
    path = File.join "test", "fixtures", name
    File.read(path)
  end

  def get_xml_doc(name)
    Nokogiri::XML::Document.parse get_fixture name
  end

  def parse_schema(name)
    WsdlMapper::Schema::Parser.new.parse get_xml_doc name
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
