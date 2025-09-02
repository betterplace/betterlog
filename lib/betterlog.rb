require 'tins/xt'
require 'json'
require 'complex_config'
require 'term/ansicolor'

# Main module for Betterlog logging functionality.
#
# Provides structured logging tools designed for betterplace's logging
# infrastructure in Rails applications. Offers thread-local metadata
# management, event formatting, severity handling, and integration with Rails
# logging systems.
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

# This class serves as a convenience alias for the Betterlog::Log module,
# providing a simple way to access the logging functionality throughout a Rails
# application
#
# @see Betterlog::Log
# @see Betterlog
class Log
end
