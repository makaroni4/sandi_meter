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

  spec.required_ruby_version = '>= 1.9.0'

  spec.files = %w(LICENSE README.md Rakefile sandi_meter.gemspec)
  spec.files += Dir.glob("html/*")
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("bin/**/*")
  spec.files += Dir.glob("spec/**/*")
  spec.executables   = ["sandi_meter"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "mixlib-cli"
  spec.add_runtime_dependency "json"
end
