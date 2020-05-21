# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faraday/conductivity/version'

Gem::Specification.new do |gem|
  gem.name          = "faraday-conductivity"
  gem.version       = Faraday::Conductivity::VERSION
  gem.authors       = ["iain", "sshao"]
  gem.email         = ["iain@iain.nl", "ssh.sshao@gmail.com"]
  gem.description   = %q{Extra Faraday middleware, geared towards a service oriented architecture.}
  gem.summary       = %q{Extra Faraday middleware, geared towards a service oriented architecture.}
  gem.homepage      = "https://github.com/enova/faraday-conductivity"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "faraday", "~> 0.8"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", "~> 3"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "service_double"
  gem.add_development_dependency "appraisal"
end
