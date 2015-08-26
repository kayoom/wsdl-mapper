require 'bundler/setup'
require 'minitest/autorun'

module TestHelper
  extend self

  def get_fixture(name)
    path = File.join "test", "fixtures", name
    File.read(path)
  end
end
