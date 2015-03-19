Gem::Specification.new do |spec|
  spec.name          = "lita-slack-karma-sync"
  spec.version       = "0.2.0"
  spec.authors       = ["Steven Harman"]
  spec.email         = ["steven@harmanly.com"]
  spec.description   = "Sync Slack user names with your lita-karma"
  spec.summary       = "Are you a Slack user? And does your team also use `lita-karma`? This plugin can be used to keep your karma terms synced up with your Slack name."
  spec.homepage      = "https://github.com/stevenharman/lita-slack-karma-sync"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/).reject {|f| f =~ %r(doc\/.+\.gif\z)}
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.1.0"

  spec.add_runtime_dependency "lita", ">= 4.2"
  spec.add_runtime_dependency "lita-slack", ">= 1.2.0"
  spec.add_runtime_dependency "lita-karma", ">= 3.0.2"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
