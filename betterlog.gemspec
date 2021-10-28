# -*- encoding: utf-8 -*-
# stub: betterlog 0.20.1 ruby lib

Gem::Specification.new do |s|
  s.name = "betterlog".freeze
  s.version = "0.20.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["betterplace Developers".freeze]
  s.date = "2021-10-28"
  s.description = "This library provides structure json logging for our rails projects".freeze
  s.email = "developers@betterplace.org".freeze
  s.executables = ["betterlog".freeze, "betterlog_pusher".freeze, "betterlog_sink".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/betterlog.rb".freeze, "lib/betterlog/global_metadata.rb".freeze, "lib/betterlog/log.rb".freeze, "lib/betterlog/log/event.rb".freeze, "lib/betterlog/log/event_formatter.rb".freeze, "lib/betterlog/log/severity.rb".freeze, "lib/betterlog/log_event_formatter.rb".freeze, "lib/betterlog/logger.rb".freeze, "lib/betterlog/notifiers.rb".freeze, "lib/betterlog/railtie.rb".freeze, "lib/betterlog/version.rb".freeze]
  s.files = [".gitignore".freeze, ".semaphore/semaphore.yml".freeze, ".tool-versions".freeze, "Dockerfile".freeze, "Gemfile".freeze, "LICENSE".freeze, "Makefile".freeze, "README.md".freeze, "Rakefile".freeze, "TODO.md".freeze, "VERSION".freeze, "betterlog.gemspec".freeze, "betterlog/config.go".freeze, "betterlog/healthz.go".freeze, "betterlog/redis_cert_cache.go".freeze, "bin/betterlog".freeze, "bin/betterlog_pusher".freeze, "bin/betterlog_sink".freeze, "cloudbuild.yaml".freeze, "cmd/betterlog-server/LICENSE".freeze, "cmd/betterlog-server/main.go".freeze, "config/log.yml".freeze, "go.mod".freeze, "go.sum".freeze, "lib/betterlog.rb".freeze, "lib/betterlog/global_metadata.rb".freeze, "lib/betterlog/log.rb".freeze, "lib/betterlog/log/event.rb".freeze, "lib/betterlog/log/event_formatter.rb".freeze, "lib/betterlog/log/severity.rb".freeze, "lib/betterlog/log_event_formatter.rb".freeze, "lib/betterlog/logger.rb".freeze, "lib/betterlog/notifiers.rb".freeze, "lib/betterlog/railtie.rb".freeze, "lib/betterlog/version.rb".freeze, "spec/betterlog/global_metadata_spec.rb".freeze, "spec/betterlog/log/event_spec.rb".freeze, "spec/betterlog/log/severity_spec.rb".freeze, "spec/betterlog/log_event_formatter_spec.rb".freeze, "spec/betterlog/log_spec.rb".freeze, "spec/betterlog/logger_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "http://github.com/betterplace/betterlog".freeze
  s.rdoc_options = ["--title".freeze, "Betterlog".freeze, "--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.2.22".freeze
  s.summary = "Structured logging support for bp".freeze
  s.test_files = ["spec/betterlog/global_metadata_spec.rb".freeze, "spec/betterlog/log/event_spec.rb".freeze, "spec/betterlog/log/severity_spec.rb".freeze, "spec/betterlog/log_event_formatter_spec.rb".freeze, "spec/betterlog/log_spec.rb".freeze, "spec/betterlog/logger_spec.rb".freeze, "spec/spec_helper.rb".freeze]

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.11.0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_development_dependency(%q<mock_redis>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.3", ">= 1.22.0"])
    s.add_runtime_dependency(%q<complex_config>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<file-tail>.freeze, ["~> 1.0"])
    s.add_runtime_dependency(%q<json>.freeze, ["~> 2.0"])
    s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
    s.add_runtime_dependency(%q<redis>.freeze, [">= 2.8"])
    s.add_runtime_dependency(%q<redlock>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<excon>.freeze, [">= 0"])
  else
    s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.11.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<mock_redis>.freeze, [">= 0"])
    s.add_dependency(%q<tins>.freeze, ["~> 1.3", ">= 1.22.0"])
    s.add_dependency(%q<complex_config>.freeze, [">= 0"])
    s.add_dependency(%q<file-tail>.freeze, ["~> 1.0"])
    s.add_dependency(%q<json>.freeze, ["~> 2.0"])
    s.add_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
    s.add_dependency(%q<redis>.freeze, [">= 2.8"])
    s.add_dependency(%q<redlock>.freeze, [">= 0"])
    s.add_dependency(%q<excon>.freeze, [">= 0"])
  end
end
