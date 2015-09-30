require 'bundler/setup'
require 'minitest/autorun'

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
end
