class Log
  class Severity
    include Comparable

    def initialize(name)
      @name = name.to_s.downcase.to_sym
      begin
        @level = ActiveSupport::Logger::Severity.const_get(@name.upcase)
      rescue NameError
        @name  = :UNKNOWN
        @level = ActiveSupport::Logger::Severity::UNKNOWN
      end
    end

    def self.all
      ActiveSupport::Logger::Severity.constants.map { |c| new(c) }
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
      to_sym
    end

    def <=>(other)
      to_i <=> other.to_i
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
