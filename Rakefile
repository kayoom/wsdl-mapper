require 'bundler/gem_tasks'

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = ['test', 'lib']
  t.pattern = 'test/wsdl_mapper*/**/*_test.rb'
  t.warning = false
end

Rake::TestTask.new :compatibility do |t|
  t.libs = ['test', 'lib']
  t.pattern = 'test/compatibility/**/*_test.rb'
  t.warning = false
end

task default: :test
task test_all: [:test, :compatibility]
