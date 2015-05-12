require 'pry'
require 'ripper'
require 'fakefs/spec_helpers'

# silence CLI output
RSpec.configure do |config|
  original_stderr = $stderr
  original_stdout = $stdout
  config.before(:all) do
    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")
  end
  config.after(:all) do
    $stderr = original_stderr
    $stdout = original_stdout
  end
end

Dir["#{Dir.pwd}/spec/support/**/*.rb"].each { |f| require f }
