require 'tins'
require 'tins/xt'
require 'betterlog/log/event'
require 'betterlog/log/event_formatter'
require 'betterlog/log/severity'

module Betterlog
  # A flexible, framework-agnostic logging solution that provides a clean API
  # for structured logging with automatic Rails integration and error recovery.
  #
  # This class implements a singleton pattern using Tins::SexySingleton and
  # automatically detects Rails environment to use its logger when available.
  # It supports structured logging with contextual information, location
  # tracking, and event notification capabilities.
  #
  # @example Basic usage
  #   Betterlog::Log.info("User logged in", meta: { user_id: 123 })
  class Log
    include Tins::SexySingleton
    extend ComplexConfig::Provider::Shortcuts

    class_attr_accessor :default_logger
    self.default_logger = Logger.new(STDERR)
    if level = cc.log?&.level?
      default_logger.level = level
    end

    # Returns the appropriate logger instance for the application.
    #
    # This method checks if Rails is defined and has a logger available,
    # falling back to a default logger otherwise.
    #
    # @return [Logger] The Rails logger if available, otherwise the default logger.
    def logger
      defined?(Rails) && Rails.respond_to?(:logger) ? Rails.logger : self.class.default_logger
    end

    # Logs a message on severity info.
    #
    # @param object this object is logged
    # @param rest additional data is logged as well.
    # @return [ Log ] this object itself.
    def info(object, **rest)
      protect do
        rest = { severity: __method__ } | rest
        emit Log::Event.ify(object, **rest)
      end
    end

    # Logs a message on severity warn.
    #
    # @param object this object is logged
    # @param rest additional data is logged as well.
    # @return [ Log ] this object itself.
    def warn(object, **rest)
      protect do
        rest = { severity: __method__ } | rest
        emit Log::Event.ify(object, **rest)
      end
    end

    # Logs a message on severity debug.
    #
    # @param object this object is logged
    # @param rest additional data is logged as well.
    # @return [ Log ] this object itself.
    def debug(object, **rest)
      protect do
        rest = { severity: __method__ } | rest
        emit Log::Event.ify(object, **rest)
      end
    end

    # Logs a message on severity error.
    #
    # @param object this object is logged
    # @param rest additional data is logged as well.
    # @return [ Log ] this object itself.
    def error(object, **rest)
      protect do
        rest = { severity: __method__ } | rest
        emit Log::Event.ify(object, **rest)
      end
    end

    # Logs a message on severity fatal.
    #
    # @param object this object is logged
    # @param rest additional data is logged as well.
    # @return [ Log ] this object itself.
    def fatal(object, **rest)
      protect do
        rest = { severity: __method__ } | rest
        emit Log::Event.ify(object, **rest)
      end
    end

    # Logs a message on severity debug, by default, this can be changed by
    # passing the severity: keyword.
    #
    # @param object this object is logged
    # @param rest additional data is logged as well.
    # @return [ Log ] this object itself.
    def output(object, **rest)
      protect do
        emit Log::Event.ify(object, **rest)
      end
    end

    # Emits a log event by adding contextual information, notifying
    # subscribers, and logging through the configured logger.
    #
    # This method enhances the provided event with location information if
    # available, sets the emitter identifier, triggers any registered
    # notifiers, and finally logs the event using the application's logger at
    # the event's severity level.
    #
    # @param event [Betterlog::Log::Event] the log event to be emitted
    # @return [Betterlog::Log] the log instance itself
    def emit(event)
      l = caller_locations.reverse_each.each_cons(3).find { |c, n1, n2|
        n2.absolute_path =~ /betterlog\/log\.rb/ and break c # TODO check if this still works
      }
      if l
        event[:location] = [ l.absolute_path, l.lineno ] * ?:
      end
      event[:emitter] = self.class.name.downcase
      notify(event)
      logger.send(event.severity.to_sym, JSON.generate(event))
      self
    end

    private

    def protect
      yield
    rescue => e
      begin
        # Try logging e once by ourselves
        emit Log::Event.ify(e, severity: :fatal)
      rescue
        # Ok, I give up let's use logger directly instead
        logger.fatal(
          "Crashed during logging with #{e.class}: #{e.message}):\n"\
          "#{e.backtrace * ?\n}"
        )
      end
      self
    end

    def build_metric(name:, value:, **rest)
      rest |= {
        message: "a metric #{name}=#{value}",
      }
      Log::Event.ify(
        {
          name:  name,
          value: value,
          type: 'metric'
        } | rest,
      )
    end

    def notify(event)
      if event.notify?
        Notifiers.notify(event)
        self
      end
    end

    thread_local :timed_duration

    def time_block(&block)
      block or return
      s = Time.now
      block.call
    ensure
      block and self.timed_duration = Time.now - s
    end
  end
end
