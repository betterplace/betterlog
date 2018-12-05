# -*- encoding: utf-8 -*-
# stub: betterdocs 0.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "betterdocs".freeze
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["betterplace Developers".freeze]
  s.date = "2018-12-05"
  s.description = "This library provides structure json logging for our rails projects".freeze
  s.email = "developers@betterplace.org".freeze
  s.extra_rdoc_files = ["README.md".freeze, "lib/betterlog.rb".freeze, "lib/betterlog/event.rb".freeze, "lib/betterlog/event_formatter.rb".freeze, "lib/betterlog/log.rb".freeze, "lib/betterlog/log_event_formatter.rb".freeze, "lib/betterlog/severity.rb".freeze]
  s.files = ["README.md".freeze, "lib/betterlog.rb".freeze, "lib/betterlog/event.rb".freeze, "lib/betterlog/event_formatter.rb".freeze, "lib/betterlog/log.rb".freeze, "lib/betterlog/log_event_formatter.rb".freeze, "lib/betterlog/severity.rb".freeze]
  s.homepage = "http://github.com/betterplace/betterdocs".freeze
  s.rdoc_options = ["--title".freeze, "Betterdocs".freeze, "--main".freeze, "README.md".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Structured logging support for bp".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<tins>.freeze, [">= 1.3.5", "~> 1.3"])
      s.add_runtime_dependency(%q<rails>.freeze, ["< 6", ">= 3"])
      s.add_runtime_dependency(%q<complex_config>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<file-tail>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<json>.freeze, ["~> 2.0"])
      s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
    else
      s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<tins>.freeze, [">= 1.3.5", "~> 1.3"])
      s.add_dependency(%q<rails>.freeze, ["< 6", ">= 3"])
      s.add_dependency(%q<complex_config>.freeze, [">= 0"])
      s.add_dependency(%q<file-tail>.freeze, ["~> 1.0"])
      s.add_dependency(%q<json>.freeze, ["~> 2.0"])
      s.add_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
    end
  else
    s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<tins>.freeze, [">= 1.3.5", "~> 1.3"])
    s.add_dependency(%q<rails>.freeze, ["< 6", ">= 3"])
    s.add_dependency(%q<complex_config>.freeze, [">= 0"])
    s.add_dependency(%q<file-tail>.freeze, ["~> 1.0"])
    s.add_dependency(%q<json>.freeze, ["~> 2.0"])
    s.add_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
  end
end
