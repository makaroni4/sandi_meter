# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sandi_meter/version'

Gem::Specification.new do |spec|
  spec.name          = "sandi_meter"
  spec.version       = SandiMeter::VERSION
  spec.authors       = ["Anatoli Makarevich"]
  spec.email         = ["makaroni4@gmail.com"]
  spec.description   = %q{Sandi Metz rules checker}
  spec.summary       = %q{Sandi Metz rules checker}
  spec.homepage      = "https://github.com/makaroni4/sandi_meter"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = ["sandi_meter"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
