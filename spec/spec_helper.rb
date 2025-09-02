require 'gem_hadar/simplecov'
GemHadar::SimpleCov.start
require 'rspec'
begin
  require 'debug'
rescue LoadError
end
require 'betterlog'
Betterlog::Log.default_logger = Logger.new(nil)
