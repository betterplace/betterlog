require 'tins'
require 'tins/xt'
require 'betterlog/log/event'
require 'betterlog/log/event_formatter'
require 'betterlog/log/severity'

module Betterlog
  class Log
    include Tins::SexySingleton

    class_attr_accessor :default_logger
    self.default_logger = Logger.new(STDERR)

    def logger
      defined?(Rails) && Rails.respond_to?(:logger) ? Rails.logger : ::Logger.new(STDERR)
    end

    # Logs a message on severity info.
    #
    # @param object this object is logged
    # @param **rest additional data is logged as well.
    # @return [ Log ] this object itself.
    def info(object, **rest)
      protect do
        emit Log::Event.ify(object, severity: __method__, rest: rest)
      end
    end

    # Logs a message on severity warn.
    #
    # @param object this object is logged
    # @param **rest additional data is logged as well.
    # @return [ Log ] this object itself.
    def warn(object, **rest)
      protect do
        emit Log::Event.ify(object, severity: __method__, rest: rest)
      end
    end

    # Logs a message on severity debug.
    #
    # @param object this object is logged
    # @param **rest additional data is logged as well.
    # @return [ Log ] this object itself.
    def debug(object, **rest)
      protect do
        emit Log::Event.ify(object, severity: __method__, rest: rest)
      end
    end

    # Logs a message on severity error.
    #
    # @param object this object is logged
    # @param **rest additional data is logged as well.
    # @return [ Log ] this object itself.
    def error(object, **rest)
      protect do
        emit Log::Event.ify(object, severity: __method__, rest: rest)
      end
    end

    # Logs a message on severity fatal.
    #
    # @param object this object is logged
    # @param **rest additional data is logged as well.
    # @return [ Log ] this object itself.
    def fatal(object, **rest)
      protect do
        emit Log::Event.ify(object, severity: __method__, rest: rest)
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
        emit Log::Event.ify(object, severity: rest[:severity], rest: rest)
      end
    end

    # Logs a metric on severity debug, by default, this can be changed by passing
    # the severity: keyword. +name+ is for example 'Donation.Confirmation' and
    # +value+ can be any value, but has to be somewhat consistent in terms of
    # structure with +name+ to allow for correct
    # evaluation.
    #
    # @param name the name of the recorded metric.
    # @param value of the recorded metric, defaults to duration if block was given.
    # @param success a Proc with parameter +result+ that returns true iff block
    #        result was asuccessful
    # @param **rest additional rest is logged as well.
    # @return [ Log ] this object itself.
    def metric(name:, value: nil, success: -> result { true }, **rest, &block)
      result = time_block(&block)
    rescue => error
      e = Log::Event.ify(error)
      rest |= e.as_json.subhash(:error_class, :backtrace, :message)
      rest[:message] = "#{rest[:message].inspect} while measuring metric #{name}"
      raise error
    ensure
      protect do
        if timed_duration
          rest[:duration] = timed_duration
        end
        event = build_metric(
          name:     name,
          value:    value || timed_duration,
          success: success.(result),
          **rest
        )
        emit event
      end
    end

    def context(data_hash)
      GlobalMetadata.add data_hash
      self
    end

    def self.context(data_hash)
      instance.context(data_hash)
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
      logger.send(event.severity.to_sym, event.to_json)
      self
    ensure
      GlobalMetadata.data.clear
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
      severity = rest.fetch(:severity, :info)
      rest |= {
        message: "a metric #{name}=#{value}",
      }
      Log::Event.ify(
        {
          name:  name,
          value: value,
          type: 'metric'
        } | rest,
        severity: severity
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
