require 'tins/xt'
require 'json'
require 'complex_config'

module Betterlog
end

require 'betterlog/log'
require 'betterlog/notifiers'
require 'betterlog/global_metadata'
require 'betterlog/logger'

if defined? Rails
  require 'betterlog/railtie'
end

Log = Betterlog::Log
