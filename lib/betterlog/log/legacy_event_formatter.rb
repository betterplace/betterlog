require 'term/ansicolor'

module Betterlog
  class Log
    # Formats log messages for legacy Rails logging compatibility.
    #
    # This class provides a formatter that integrates with Rails' legacy
    # logging system, converting standard log messages into structured JSON
    # events while preserving the original formatting behavior for backward
    # compatibility.
    #
    # @see Betterlog::Log::Event
    # @see ActiveSupport::Logger::Formatter
    class LegacyEventFormatter < ::ActiveSupport::Logger::Formatter
      include ActiveSupport::TaggedLogging::Formatter
      include ComplexConfig::Provider::Shortcuts

      # Returns the emitter identifier string for legacy log events.
      #
      # This method provides a constant string value that represents the
      # emitter type for logs formatted using the legacy event formatter.
      #
      # @return [ String ] the string 'legacy' indicating the legacy emitter type
      def emitter
        'legacy'
      end

      # Processes a log message using the legacy formatting approach.
      #
      # This method handles the conversion of standard log messages into
      # structured JSON events when legacy logging support is enabled. It
      # extracts relevant information from the input message, such as
      # backtraces and location data, and formats it according to the legacy
      # event structure.
      #
      # @param severity [ String ] the severity level of the log message
      # @param timestamp [ Time ] the time when the log entry was created
      # @param program [ String ] the name of the program generating the log
      # @param message [ String ] the raw log message content
      #
      # @return [ String ] the formatted log message, either as a JSON event or
      #   the original message if it's not suitable for conversion
      def call(severity, timestamp, program, message)
        if cc.log.legacy_supported
          if message.blank?
            message = ''
          elsif !Log::Event.is?(message)

            m = message.to_s
            m = Term::ANSIColor.uncolor(m)
            m = m.sub(/\s+$/, '')

            timestamp = timestamp.utc.iso8601(3)
            event = Log::Event.new(
              emitter:    emitter,
              timestamp:  timestamp,
              message:    m,
              severity:   severity.to_s.downcase,
              # tags:       current_tags,
            )
            backtrace = m.scan(/^\s*(?:[^:]+):(?:\d+).*$/)
            if backtrace.size > 1
              event[:backtrace] = backtrace.map { |b| b.sub(/\s+$/, '') }
              event[:message] = "#{backtrace.first}\n"
            end
            if l = caller_locations.reverse_each.each_cons(2).find { |c, n|
              n.absolute_path =~ /\/lib\/ruby\/.*?\/logger\.rb/ and break c
            }
              then
              event[:location] = [ l.absolute_path, l.lineno ] * ?:
            end
            program and event[:program] = program
            message = JSON.generate(event)
          end
        end
      rescue => e
        Betterlog::Log.logger.error(e)
      ensure
        message = message.to_s
        # Do not "message << ?\n" - A frozen string may be passed in
        message.end_with?(?\n) or message = "#{message}\n"
        return message
      end
    end
  end
end
