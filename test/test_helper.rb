require 'bundler/setup'

if ENV['cov']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'abstract_.*\.rb'
    add_filter 'wsdl_mapper_testing/'
  end
end

require 'minitest/autorun'
require 'minitest/focus'

require 'nokogiri'

require 'wsdl_mapper_testing/tmp_path'

TEST_TMP_PATH = File.join 'test', 'tmp'
TEST_FIXTURE_PATH = File.join 'test', 'fixtures'

require 'wsdl_mapper_testing/test_helper'
require 'wsdl_mapper_testing/generation_test'

include WsdlMapperTesting
