require 'tins'
require 'tins/xt'
require 'betterlog/log/event'
require 'betterlog/log/event_formatter'
require 'betterlog/log/severity'

module Betterlog
  class Log
    include Tins::SexySingleton
    extend ComplexConfig::Provider::Shortcuts

    class_attr_accessor :default_logger
    self.default_logger = Logger.new(STDERR)
    if level = cc.log?&.level?
      default_logger.level = level
    end

    def logger
      defined?(Rails) && Rails.respond_to?(:logger) ? Rails.logger : self.class.default_logger
    end

    # Logs a message on severity info.
    #
    # @param object this object is logged
    # @param **rest additional data is logged as well.
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
    # @param **rest additional data is logged as well.
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
    # @param **rest additional data is logged as well.
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
    # @param **rest additional data is logged as well.
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
    # @param **rest additional data is logged as well.
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
    # @param **rest additional data is logged as well.
    # @return [ Log ] this object itself.
    def output(object, **rest)
      protect do
        emit Log::Event.ify(object, **rest)
      end
    end

    def metric(name:, value: nil, success: -> result { true }, **rest, &block)
      warn "#{self.class}##{__method__} is deprecated"
    end

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
