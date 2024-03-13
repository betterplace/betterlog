require 'term/ansicolor'

module Betterlog
  class Log
    class LegacyEventFormatter < ::ActiveSupport::Logger::Formatter
      include ActiveSupport::TaggedLogging::Formatter
      include ComplexConfig::Provider::Shortcuts

      def emitter
        'legacy'
      end

      def call(severity, timestamp, program, message)
        if cc.log.legacy_supported
          if message.blank?
            message = ''
          elsif !Log::Event.is?(message)

            m = message.to_s
            m = Term::ANSIColor.uncolor(m)
            m = m.sub(/\s+$/, '')

            timestamp = timestamp.utc.iso8601(3)
            event = Log::Event.new({
              emitter:    emitter,
              timestamp:  timestamp,
              message:    m,
              severity:   severity.to_s.downcase,
              # tags:       current_tags,
              meta: (
                Sidekiq::Context.current&.symbolize_keys_recursive if defined?(Sidekiq::Context.current)
              )}.compact
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
