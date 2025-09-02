require 'socket'

module Betterlog
  class Log
    # A structured logging event representation.
    #
    # This class encapsulates log event data with standardized formatting and
    # metadata enrichment. It provides methods for creating, formatting, and
    # serializing log events while ensuring consistent structure and
    # compatibility with various logging systems.
    #
    # @see Betterlog::Log::EventFormatter
    # @see Betterlog::Log::Severity
    # @see Betterlog::GlobalMetadata
    class Event
      # Converts an input argument into a log event object with standardized
      # formatting.
      #
      # This method processes various types of input including exceptions,
      # strings, and hashes, transforming them into structured log events while
      # preserving or enhancing their metadata. It ensures consistent event
      # creation by normalizing keys and applying default values
      # where necessary.
      #
      # @param arg [ Object ] the input argument to be converted into a log event
      # @param rest [ Hash ] additional key-value pairs to be merged into the resulting event
      # @return [ Betterlog::Log::Event ] a new log event instance created from the input argument
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

      # Parses a JSON string into a new log event instance.
      #
      # This method takes a JSON representation of a log event and converts it
      # into a structured event object. It attempts to parse the JSON string
      # and create a new event using the parsed data. If the JSON is malformed
      # or cannot be parsed, the method silently rescues the error and returns
      # nil.
      #
      # @param json [ String ] a JSON-formatted string representing a log event
      # @return [ Betterlog::Log::Event, nil ] a new log event instance if
      # parsing succeeds, nil otherwise
      def self.parse(json)
        new(JSON.parse(json))
      rescue JSON::ParserError
      end

      # Checks if a JSON string represents a log event with emitter data.
      #
      # This method attempts to parse a JSON string and determine whether it
      # contains a log event structure by checking for the presence of an
      # 'emitter' key in the parsed data. It returns true if the JSON is valid
      # and contains the emitter key, false otherwise.
      #
      # @param json [ String ] A JSON-formatted string to check
      # @return [ Boolean ] true if the JSON represents a log event with
      # emitter data, false if not or if parsing fails
      def self.is?(json)
        if json = json.ask_and_send(:to_str)
          data = JSON.parse(json).ask_and_send(:to_hash)
          data&.key?('emitter')
        end
      rescue JSON::ParserError
        false
      end

      # Initializes a new log event with the provided data.
      #
      # This constructor processes the input data by normalizing keys, computing
      # default values for missing fields, and setting up the event's severity level.
      # It ensures that all log events have consistent structure and required fields
      # such as timestamp, PID, program name, and host information.
      #
      # @param data [ Hash ] a hash containing the initial data for the log event
      # @return [ Betterlog::Log::Event ] a new log event instance with processed data
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

      # Returns a duplicate of the internal data hash for JSON serialization.
      #
      # This method provides access to the log event's underlying data
      # structure by returning a shallow copy of the internal @data instance
      # variable. It is primarily used to enable JSON serialization of log
      # events while ensuring that modifications to the returned hash do not
      # affect the original event data.
      #
      # @return [ Hash ] a duplicate of the internal data hash containing all
      #   log event attributes and metadata
      def as_json(*a)
        @data.dup
      end

      # Converts the log event to a JSON string representation.
      #
      # This method generates a JSON-encoded string of the log event's data,
      # providing a structured format suitable for logging and transmission.
      # In cases where JSON generation fails due to encoding issues or other errors,
      # it falls back to a minimal JSON representation containing only the severity
      # and a cleaned-up message to ensure logging functionality remains intact.
      #
      # @return [ String ] A JSON string representation of the log event
      # @see #as_json
      # @see JSON.generate
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

      # Formats the log event using the specified formatting options.
      #
      # This method delegates to an EventFormatter instance to process the log
      # event according to the provided arguments, enabling flexible output
      # generation including JSON representation and pretty-printed strings
      # with optional colorization.
      #
      # @param args [ Hash ] A hash of formatting options to control the output format
      # @return [ String ] The formatted string representation of the log event
      def format(**args)
        Log::EventFormatter.new(self).format(**args)
      end

      alias to_s format

      # Sets a value in the event data hash using the provided name as a key.
      #
      # This method allows for direct assignment of a value to a specific key
      # within the log event's internal data structure. The key is converted to a
      # symbol before being used to store the value, ensuring consistency with
      # the internal storage format.
      #
      # @param name [ String, Symbol ] the key to set in the event data
      # @param value [ Object ] the value to associate with the given key
      # @return [ Object ] the assigned value
      def []=(name, value)
        @data[name.to_sym] = value
      end

      # Retrieves a value from the event data hash using the provided name as a key.
      #
      # This method allows for access to specific fields stored within the log
      # event's internal data structure by converting the provided name to a
      # symbol and using it to look up the corresponding value.
      #
      # @param name [ String, Symbol ] the key used to retrieve the value from
      # the event data
      # @return [ Object, nil ] the value associated with the given key, or nil
      # if the key does not exist
      def [](name)
        @data[name.to_sym]
      end

      # Returns the severity level of the log event.
      #
      # This method provides access to the severity attribute that was assigned
      # to the log event during its initialization. The severity indicates the
      # importance or urgency of the log message, such as debug, info, warn,
      # error, or fatal levels.
      #
      # @return [ Betterlog::Log::Severity ] the severity level object associated
      #   with this log event
      def severity
        @data[:severity]
      end

      # Returns the emitter identifier associated with the log event.
      #
      # This method provides access to the emitter field stored within the log
      # event's data hash. The emitter typically indicates the source or type
      # of system that generated the log entry, helping to categorize and route
      # log messages appropriately.
      #
      # @return [ String, nil ] the emitter identifier if set, otherwise nil
      def emitter
        @data[:emitter]
      end

      # Returns the notification flag from the log event data.
      #
      # This method retrieves the value associated with the :notify key from
      # the event's internal data hash. The return value indicates whether the
      # log event should trigger notifications to registered notifiers.
      #
      # @return [ Object, nil ] the notification setting from the event data,
      # or nil if not set
      def notify?
        @data[:notify]
      end

      # Checks equality between this log event and another object based on
      # their internal data.
      #
      # This method compares the internal data hash of this log event with that
      # of another object to determine if they contain identical content. It
      # accesses the private @data instance variable from both objects and uses
      # the built-in eql? method for hash comparison to ensure a deep equality
      # check.
      #
      # @param other [ Object ] the object to compare against, expected to be another
      #   Betterlog::Log::Event instance
      # @return [ TrueClass, FalseClass ] true if both objects have equal internal data,
      #   false otherwise
      def eql?(other)
        @data.eql? other.instance_variable_get(:@data)
      end

      alias == eql?

      # Returns the hash value corresponding to the event's data.
      #
      # This method provides access to the cached hash representation of the
      # internal data hash, which is used for consistent identification and
      # comparison operations within the logging system. The returned hash
      # value is derived from the event's current data state and remains stable
      # as long as the data does not change.
      #
      # @return [ Integer ] the hash value of the event's internal data structure
      def hash
        @data.hash
      end

      private

      # Processes input data to compute and enrich log event information.
      #
      # This method takes raw log data and enriches it with default values for
      # standard log fields such as timestamp, process ID, program name, and
      # host information. It also merges in global metadata and Sidekiq context
      # information when available to provide comprehensive context for the log
      # event.
      #
      # @param data [ Hash ] the raw input data to be processed and enriched
      # @return [ Hash ] the processed data hash with default values and metadata merged in
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
