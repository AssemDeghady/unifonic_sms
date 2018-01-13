
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "unifonic_sms/version"

Gem::Specification.new do |spec|
  spec.name          = "unifonic_sms"
  spec.version       = UnifonicSms::VERSION
  spec.required_ruby_version = '>= 2.3.0'

  spec.authors       = ["Assen Deghady"]
  spec.email         = ["assem.deghady@gmail.com"]

  spec.summary       = %q{Send SMS messages using Unifonic Api.}
  spec.homepage      = "https://github.com/AssemDeghady/unifonic_sms"
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*.rb']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", '~> 3.1', '>= 3.1.1'

end
