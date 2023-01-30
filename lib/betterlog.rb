require 'tins/xt'
require 'json'
require 'complex_config'
require 'term/ansicolor'

module Betterlog
end

require 'betterlog/version'
require 'betterlog/log'
require 'betterlog/notifiers'
require 'betterlog/global_metadata'

if defined? Rails
  require 'betterlog/railtie'
end

Log = Betterlog::Log
