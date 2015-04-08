require 'pry'
require 'rspec/autorun'
require 'ripper'
require 'fakefs/spec_helpers'

Dir["#{Dir.pwd}/spec/support/**/*.rb"].each { |f| require f }
