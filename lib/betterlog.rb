require 'tins/xt'
require 'json'
require 'logger'
require 'time'
require 'complex_config'
require 'term/ansicolor'

module Betterlog
end

require 'betterlog/log'
require 'betterlog/notifiers'
require 'betterlog/global_metadata'
require 'betterlog/logger'

if defined? Rails
  require 'betterlog/log_event_formatter'
  require 'betterlog/railtie'
end

Log = Betterlog::Log
