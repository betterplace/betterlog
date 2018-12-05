# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'betterlog'
  author      'betterplace Developers'
  email       'developers@betterplace.org'
  homepage    "http://github.com/betterplace/#{name}"
  summary     'Structured logging support for bp'
  description "This library provides structure json logging for our rails projects"
  test_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage', '.rvmrc',
    '.ruby-version', '.AppleDouble', 'tags', '.DS_Store', '.utilsrc',
    '.bundle', '.byebug_history', 'errors.lst', '.yardoc'
  readme      'README.md'
  title       "#{name.camelize}"
  executables ["betterlog"]

  dependency 'tins',           '~>1.3', '>=1.3.5'
  dependency 'rails',          '>=3', '<6'
  dependency 'complex_config'
  dependency 'file-tail',      '~>1.0'
  dependency 'json',           '~>2.0'
  dependency 'term-ansicolor', '~>1.3'

  development_dependency 'rake'
end

task :default => :spec
