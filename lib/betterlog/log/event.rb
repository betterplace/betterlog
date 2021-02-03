module Betterlog
  class Log
    class Event
      require 'socket'

      def self.ify(arg, severity: :debug, notify: nil, rest: {})
        notify ||= rest.delete(:notify)
        if e = arg.ask_and_send(:exception)
          ify(
            {
              error_class:  e.class.name,
              message:      "#{e.class.name}: #{e.message}",
              backtrace:    e.backtrace,
            },
            severity: severity,
            rest: rest,
            notify: notify,
          )
        elsif s = arg.ask_and_send(:to_str)
          new(
            ({ notify: s } if notify).to_h |
            {
              message:  s,
              severity: severity,
            } | rest
          )
        elsif h = arg.ask_and_send(:to_hash)
          arg = h | { severity: severity } | rest
          new(
            ({ notify: h[:message] || arg.to_s } if notify).to_h |
            arg
          )
        else
          message = "Logging #{arg.inspect}"
          new(
            ({ notify: message } if notify).to_h |
            {
              message: message,
              severity: severity,
            } | rest
          )
        end
      end

      def self.parse(json)
        new(JSON.parse(json))
      rescue JSON::ParserError
      end

      def self.is?(json)
        if json = json.ask_and_send(:to_str)
          data = JSON.parse(json).ask_and_send(:to_hash)
          data&.key?('emitter')
        end
      rescue JSON::ParserError
        false
      end

      def initialize(data = {})
        data = data.symbolize_keys_recursive(circular: :circular) | meta
        unless data.key?(:message)
          data[:message] = "a #{data[:type]} type log message of severity #{data[:severity]}"
        end
        data[:severity] =
          begin
            Severity.new((data[:severity] || :debug))
          rescue
            Severity.new(:debug)
          end
        @data = Hash[data.sort_by(&:first)]
      end

      def as_json(*a)
        @data.dup
      end

      def to_json(*a)
        JSON.generate(as_json)
      rescue
        # Sometimes rails logging messages contain invalid utf-8 characters
        # generating various standard errors. Let's fallback to a barebones
        # event with just a cleaned up message for these cases.
        JSON.generate({
          severity: @data[:severity],
          message: @data.fetch(:message, '').encode('utf-8', invalid: :replace, undef: :replace, replace: ''),
        })
      end

      def format(*args)
        Log::EventFormatter.new(self).format(*args)
      end

      alias to_s format

      def []=(name, value)
        @data[name.to_sym] = value
      end

      def [](name)
        @data[name.to_sym]
      end

      def severity
        @data[:severity]
      end

      def emitter
        @data[:emitter]
      end

      def notify?
        @data[:notify]
      end

      def eql?(other)
        @data.eql? other.instance_variable_get(:@data)
      end

      alias == eql?

      def hash
        @data.hash
      end

      private

      def meta
        m = {
          timestamp: Time.now.utc.iso8601(3),
          pid:       $$,
          program:   File.basename($0),
          severity:  :debug,
          type:      'rails',
          facility:  'local0',
          host:      (Socket.gethostname rescue nil),
          thread_id:  Thread.current.object_id
        }
        if defined? GlobalMetadata
          m |= GlobalMetadata.data
        end
        m
      end
    end
  end
end
