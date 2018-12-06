class LogEventFormatter < ActiveSupport::Logger::Formatter
  include ActiveSupport::TaggedLogging::Formatter

  def emitter
    'legacy'
  end

  def call(severity, timestamp, program, message)
    super
    message = message.to_s
    if cc.log.legacy_supported
      if message.blank?
        return ''
      elsif !Log::Event.is?(message)
        m = message.sub(/\s+$/, '')
        timestamp = timestamp.utc.iso8601(3)
        event = Log::Event.new(
          emitter:    emitter,
          timestamp:  timestamp,
          message:    m,
          severity:   severity.to_s.downcase,
          # tags:       current_tags,
        )
        if backtrace = m.grep(/^\s*([^:]+):(\d+)/)
          if backtrace.size > 1
            event[:backtrace] = backtrace.map(&:chomp)
            event[:message] = 'a logged backtrace'
          end
        end
        if l = caller_locations.reverse_each.each_cons(2).find { |c, n|
             n.absolute_path =~ /\/lib\/ruby\/.*?\/logger\.rb/ and break c
          }
        then
          event[:location] = [ l.absolute_path, l.lineno ] * ?:
        end
        program and event[:program] = program
        message = event.to_json
      end
    end
  rescue => e
    Rails.logger.error(e)
  ensure
    # Do not "message << ?\n" - A frozn string may be passed in
    message.end_with?(?\n) or message = "#{message}\n"
    return message
  end
end
