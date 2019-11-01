module Betterlog
  class Log
    class Severity
      include ::Logger::Severity
      include Comparable

      class << self
        thread_local :shared

        def new(name)
          name = name.to_sym if self.class === name
          name = name.to_s.upcase.to_sym
          self.shared ||= {}
          shared[name] ||= super(name).freeze
        end
      end

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

      def self.all
        @all_constants ||= constants.map { |c| new(c) }
      end

      def to_i
        @level
      end

      def to_s
        @name.to_s.upcase
      end

      def to_sym
        @name
      end

      def as_json(*)
        to_s
      end

      def <=>(other)
        to_i <=> self.class.new(other).to_i
      end

      def eql?(other)
        to_sym == other.to_sym
      end

      alias == eql?

      def hash
        @name.hash
      end
    end
  end
end
