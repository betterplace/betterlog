if ENV['START_SIMPLECOV'].to_i == 1
  require 'simplecov'
  SimpleCov.start do
    add_filter "#{File.basename(File.dirname(__FILE__))}/"
  end
end
require 'rspec'
begin
  require 'debug'
rescue LoadError
end
require 'betterlog'
Betterlog::Log.default_logger = Logger.new(nil)
