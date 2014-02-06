require 'rake/testtask'
require 'bundler'

Bundler::GemHelper.install_tasks

Rake::TestTask.new do |test|
  test.verbose = true
  test.libs << "spec"
  test.test_files = FileList['spec/**/*_spec.rb']
end

task default: :test

task :debug do
  require "sandi_meter/cli"

  SandiMeter::CLI.execute
end
