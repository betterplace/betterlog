require 'gem_hadar/simplecov'
GemHadar::SimpleCov.start
begin
  require 'debug'
rescue LoadError
end
require 'betterlog'
Betterlog::Log.default_logger = Logger.new(nil)
