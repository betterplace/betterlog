require 'tins'
require 'tins/xt'
require 'betterlog/log/event'
require 'betterlog/log/severity'

class Log
  include Tins::SexySingleton

  def logger
    Rails.logger
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
  # the severity: keyword.
  #
  # @param metric the name of the recorded metric.
  # @param type of the recorded metric.
  # @param value of the recorded metric.
  # @param **rest additional rest is logged as well.
  # @return [ Log ] this object itself.
  def metric(metric:, type:, value:, **rest)
    protect do
      event = build_metric(metric: metric, type: type, value: value, **rest)
      emit event
    end
  end

  # Logs a time measure on severity debug, by default, this can be changed by
  # passing the severity: keyword.
  #
  # If an error occurs during measurement details about it are added to the
  # metric event.
  #
  # @param metric the name of the recorded metric.
  # @param **rest additional rest is logged as well.
  # @param block the block around which the measure is teaken.
  # @return [ Log ] this object itself.
  def measure(metric:, **rest, &block)
    raise ArgumentError, 'must be called with a block' unless block_given?
    time_block { yield }
  rescue => error
    e = Log::Event.ify(error)
    rest |= e.as_hash.subhash(:error_class, :backtrace, :message)
    rest[:message] = "#{rest[:message]} while measuring metric #{metric}"
    raise error
  ensure
    protect do
      event = build_metric(metric: metric, type: 'seconds', value: timed_duration, **rest)
      emit event
    end
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

  def build_metric(metric:, type:, value:, **rest)
    severity = rest.fetch(:severity, :debug)
    rest |= {
      message: "a metric #{metric} of type #{type}",
    }
    Log::Event.ify(
      {
        metric: metric,
        type: type,
        value: value,
      } | rest,
      severity: severity
    )
  end

  def emit(event)
    if l = caller_locations.reverse_each.each_cons(3).find { |c, n1, n2|
      n2.absolute_path =~ /app\/lib\/log\.rb/ and break c
    }
      then
      event[:location] = [ l.absolute_path, l.lineno ] * ?:
    end
    event[:emitter] = self.class.name.downcase
    if event.notify?
      notify(event)
    end
    logger.send(event.severity.to_sym, event.to_json)
    self
  end

  def notify(event)
    Honeybadger.notify(event.notify?, event.as_hash)
  end

  thread_local :timed_duration

  def time_block
    s = Time.now
    yield
  ensure
    self.timed_duration = Time.now - s
  end
end
