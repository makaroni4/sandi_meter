require 'rake/testtask'

Rake::TestTask.new do |test|
  test.verbose = true
  test.libs << "test"
  test.test_files = FileList['test/**/*_test.rb']
end

task default: :test
