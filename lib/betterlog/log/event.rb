module Betterlog
  class Log
    class Event
      require 'socket'

      def self.ify(arg, **rest)
        rest = rest.symbolize_keys_recursive(circular: :circular)
        if e = arg.ask_and_send(:exception)
          new(
            {
              error_class:  e.class.name,
              message:      "#{e.class.name}: #{e.message}",
              backtrace:    e.backtrace,
            } | rest
          )
        elsif message = arg.ask_and_send(:to_str)
          new({ message: } | rest)
        elsif hash = arg.ask_and_send(:to_hash)
          new(hash | rest)
        else
          message = "Logging #{arg.inspect}"
          new({ message: } | rest)
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
        data = compute_data(data.symbolize_keys_recursive(circular: :circular))
        data[:severity] =
          begin
            Severity.new((data[:severity] || :debug))
          rescue
            Severity.new(:debug)
          end
        unless data.key?(:message)
          data[:message] = "a #{data[:type]} type log message of severity #{data[:severity]}"
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

      def format(**args)
        Log::EventFormatter.new(self).format(**args)
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

      def compute_data(data)
        d = data | {
          timestamp: Time.now.utc.iso8601(3),
          pid:       $$,
          program:   File.basename($0),
          severity:  :debug,
          type:      'rails',
          facility:  'local0',
          host:      (Socket.gethostname rescue nil),
          thread_id: Thread.current.object_id,
        }
        d[:meta] ||= {}
        d[:meta] |= (GlobalMetadata.current |
          (Sidekiq::Context.current&.symbolize_keys_recursive if defined?(Sidekiq::Context)))
        d
      end
    end
  end
end
