require 'logger'

module Betterlog
  class Log
    # A severity level representation for logging events.
    #
    # This class provides a structured way to handle logging severity levels,
    # ensuring consistent formatting and comparison of severity values. It
    # integrates with Ruby's standard Logger::Severity constants while
    # providing additional functionality for normalization, caching, and
    # comparison operations.
    #
    # @see Betterlog::Log::Event
    # @see Logger::Severity
    class Severity
      include ::Logger::Severity
      include Comparable

      class << self

        # Defines a thread-local variable named shared within the class.
        #
        # This method sets up a thread-local storage area called shared,
        # which can be used to store data that is unique to each thread.
        # It is typically used to maintain state or caches that should
        # not be shared across different threads in a multi-threaded environment.
        thread_local :shared

        # Creates a new Severity instance with the given name, normalizing it
        # to uppercase symbols for consistent lookup.
        #
        # This method converts the input name to a standardized format by
        # converting it to a symbol, uppercasing its string representation, and
        # then attempting to retrieve or create a corresponding Severity
        # constant. It ensures that only one instance exists per unique
        # severity name by using a shared cache.
        #
        # @param name [ String, Symbol, Betterlog::Log::Severity ] the severity
        # name to initialize with
        # @return [ Betterlog::Log::Severity ] a new or cached severity instance
        def new(name)
          name = name.to_sym if self.class === name
          name = name.to_s.upcase.to_sym
          self.shared ||= {}
          shared[name] ||= super(name).freeze
        end
      end

      # Initializes a new Severity instance with the given name.
      #
      # This constructor creates a severity level object by converting the
      # input name to a standardized symbol format and attempting to map it to
      # a corresponding logger severity constant. If the constant is not found,
      # it defaults to the UNKNOWN severity level.
      #
      # @param name [ String, Symbol, Betterlog::Log::Severity ] the severity name
      #   to initialize with, which will be converted to uppercase and normalized
      #   to a symbol for lookup
      # @return [ Betterlog::Log::Severity ] a new severity instance
      def initialize(name)
        name = name.to_sym if self.class === name
        @name = name.to_s.downcase.to_sym
        begin
          @level = self.class.const_get(@name.to_s.upcase)
        rescue NameError
          @name  = :unknown
          @level = UNKNOWN
        end
      end

      # Returns an array of all Severity constants as initialized objects.
      #
      # This method retrieves all available severity constants defined in the
      # class and creates a new instance of Severity for each one. The results
      # are cached in an instance variable to avoid re-computation on
      # subsequent calls.
      #
      # @return [ Array<Betterlog::Log::Severity> ] an array containing Severity
      #   instances for each constant defined in the class
      def self.all
        @all_constants ||= constants.map { |c| new(c) }
      end

      # Converts the severity level to its integer representation.
      #
      # This method returns the underlying integer value that represents the
      # severity level, which corresponds to standard logging severity
      # constants.
      #
      # @return [ Integer ] the integer value of the severity level
      def to_i
        @level
      end

      # Converts the severity name to an uppercase string representation.
      #
      # This method returns a string version of the severity name, converted to
      # uppercase for consistent formatting and display purposes.
      #
      # @return [ String ] the uppercase string representation of the severity name
      def to_s
        @name.to_s.upcase
      end

      # Converts the severity name to a symbol representation.
      #
      # This method returns the internal symbol representation of the severity
      # name, which is used for consistent identification and comparison of
      # severity levels.
      #
      # @return [ Symbol ] the symbol representation of the severity name
      def to_sym
        @name
      end

      # Converts the log event to a JSON-compatible hash representation.
      #
      # This method provides a way to serialize the log event data into a
      # format suitable for JSON generation, ensuring that the event's data can
      # be easily converted to a JSON string while maintaining its structure
      # and content.
      #
      # @return [ Hash ] a hash representation of the log event data
      def as_json(*)
        to_s
      end

      # Compares this severity instance with another value for ordering.
      #
      # This method enables sorting and comparison of severity levels by
      # converting both the current instance and the provided value to their
      # integer representations and performing a standard numeric comparison.
      #
      # @param other [ Object ] the value to compare against, which will be converted
      #   to a Severity instance for comparison
      # @return [ Integer ] -1 if this instance is less than the other, 0 if they are
      #   equal, 1 if this instance is greater than the other
      def <=>(other)
        to_i <=> self.class.new(other).to_i
      end

      # Checks equality between this severity instance and another object based
      # on their symbol representations.
      #
      # This method compares the symbol representation of the current severity
      # instance with that of another object to determine if they are
      # equivalent.
      #
      # @param other [ Object ] the object to compare against
      # @return [ TrueClass, FalseClass ] true if both objects have equal
      # symbol representations, false otherwise
      def eql?(other)
        to_sym == other.to_sym
      end

      alias == eql?

      # Returns the hash value corresponding to the severity name symbol.
      #
      # This method provides a hash representation of the internal symbol
      # identifier for the severity level, which is used for consistent
      # identification and comparison operations within the logging system.
      #
      # @return [ Integer ] the hash value of the severity name symbol
      def hash
        @name.hash
      end
    end
  end
end
