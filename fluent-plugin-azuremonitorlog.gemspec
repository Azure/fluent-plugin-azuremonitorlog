# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-azuremonitorlog"
  gem.version       = "0.0.1"
  gem.authors       = ["Ilana Kantorov"]
  gem.email         = ["ilanak@microsoft.com"]
  gem.description   = %q{Input plugin for Azure Monitor Activity logs.}
  gem.homepage      = "https://github.com/Ilanak/fluent-plugin-azureamonitorlog"
  gem.summary       = gem.description
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "fluentd", ">= 0.10.30"
  gem.add_dependency "azure_mgmt_monitor", "~> 0.11.0"
  gem.add_development_dependency "rake", ">= 0.9.2"
  gem.add_development_dependency "test-unit", ">= 3.1.0"
  gem.license = 'MIT'
end
