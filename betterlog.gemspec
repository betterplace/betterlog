# -*- encoding: utf-8 -*-
# stub: betterlog 2.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "betterlog".freeze
  s.version = "2.2.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["betterplace Developers".freeze]
  s.date = "1980-01-02"
  s.description = "This library provides structure json logging for our rails projects".freeze
  s.email = "developers@betterplace.org".freeze
  s.executables = ["betterlog".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/betterlog.rb".freeze, "lib/betterlog/global_metadata.rb".freeze, "lib/betterlog/log.rb".freeze, "lib/betterlog/log/event.rb".freeze, "lib/betterlog/log/event_formatter.rb".freeze, "lib/betterlog/log/legacy_event_formatter.rb".freeze, "lib/betterlog/log/severity.rb".freeze, "lib/betterlog/notifiers.rb".freeze, "lib/betterlog/railtie.rb".freeze, "lib/betterlog/version.rb".freeze]
  s.files = ["CHANGES.md".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "VERSION".freeze, "betterlog.gemspec".freeze, "bin/betterlog".freeze, "config/log.yml".freeze, "lib/betterlog.rb".freeze, "lib/betterlog/global_metadata.rb".freeze, "lib/betterlog/log.rb".freeze, "lib/betterlog/log/event.rb".freeze, "lib/betterlog/log/event_formatter.rb".freeze, "lib/betterlog/log/legacy_event_formatter.rb".freeze, "lib/betterlog/log/severity.rb".freeze, "lib/betterlog/notifiers.rb".freeze, "lib/betterlog/railtie.rb".freeze, "lib/betterlog/version.rb".freeze, "spec/betterlog/global_metadata_spec.rb".freeze, "spec/betterlog/log/event_spec.rb".freeze, "spec/betterlog/log/legacy_event_formatter_spec.rb".freeze, "spec/betterlog/log/severity_spec.rb".freeze, "spec/betterlog/log_spec.rb".freeze, "spec/betterlog/version_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "http://github.com/betterplace/betterlog".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rdoc_options = ["--title".freeze, "Betterlog".freeze, "--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new("~> 3.2".freeze)
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Structured logging support for bp".freeze
  s.test_files = ["spec/betterlog/global_metadata_spec.rb".freeze, "spec/betterlog/log/event_spec.rb".freeze, "spec/betterlog/log/legacy_event_formatter_spec.rb".freeze, "spec/betterlog/log/severity_spec.rb".freeze, "spec/betterlog/log_spec.rb".freeze, "spec/betterlog/version_spec.rb".freeze, "spec/spec_helper.rb".freeze]

  s.specification_version = 4

  s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 2.8".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<debug>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<all_images>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.47".freeze])
  s.add_runtime_dependency(%q<complex_config>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<file-tail>.freeze, ["~> 1.0".freeze])
  s.add_runtime_dependency(%q<json>.freeze, ["~> 2.0".freeze])
  s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.3".freeze])
  s.add_runtime_dependency(%q<redlock>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<excon>.freeze, [">= 0".freeze])
end
