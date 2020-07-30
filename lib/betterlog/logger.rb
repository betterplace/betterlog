require 'redis'

module Betterlog
  class Logger < ::Logger
    include ComplexConfig::Provider::Shortcuts

    def initialize(redis, shift_age = 0, shift_size = 1048576, name: nil, buffer_size: nil, **opts)
      @redis       = redis
      @fallback    = ::Logger.new(STDERR)
      if level = cc.log.level?
        self.level      = level
        @fallback.level = level
      end
      @name        = name || self.class.name
      @buffer_size = determine_buffer_size(buffer_size)
      super(nil, shift_age, shift_size, **opts)
    end

    def self.for_redis_url(url, shift_age = 0, shift_size = 1048576,  **opts)
      redis = Redis.new(url: url)
      redis.ping
      new(redis, shift_age, shift_size, **opts)
    rescue Redis::CannotConnectError
    end

    private def determine_buffer_size(buffer_size)
      if buffer_size.nil? || buffer_size < 1 * 1024 ** 2
        1 * 1024 ** 2 # Default to very small buffer
      elsif buffer_size > 511 * 1024 ** 2
        511 * 1024 ** 2 # Stay well below redis' 512Mb upper limit for strings
      else
        buffer_size
      end
    end

    private def redis_write(msg)
      # Stop before reaching configured buffer_size limit, after warning a lot.
      if @redis.strlen(@name) > (@buffer_size * 96) / 100
        @fallback.error("Redis memory limit will soon be reached =>"\
          " Log output to redis stops now unless log data is pushed away!")
        return nil
      end
      @redis.append @name, msg
      self
    end


    def add(severity, message = nil, progname = nil)
      severity ||= UNKNOWN
      if severity < @level
        return true
      end
      if progname.nil?
        progname = @progname
      end
      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
          progname = @progname
        end
      end
      redis_write(
        format_message(format_severity(severity), Time.now, progname, message))
      true
    rescue Redis::BaseConnectionError
      @fallback.add(severity, message, progname)
    end

    def <<(msg)
      redis_write(msg)
    rescue Redis::BaseConnectionError
      @fallback << msg
    end

    def clear
      @redis.del @name
      self
    end

    def each_chunk(chunk_size: 100 * 1024, &block)
      chunk_size > 0 or raise ArgumentError, 'chunk_size > 0 required'

      # Delete any remaining temporary keys if we were interrtupted earlier
      # (or in some other process.)
      @redis.scan_each(match: "#{@name}_*") do |key|
        @redis.del key
      rescue Redis::BaseConnectionError
      end

      @redis.exists?(@name) or return Enumerator.new {}

      Enumerator.new do |y|
        name_tmp = "#{@name}_#{rand}"
        @redis.rename @name, name_tmp

        s = 0
        e = @redis.strlen(name_tmp) - 1
        until s > e
          range = @redis.getrange(name_tmp, s, s + chunk_size - 1)
          range.force_encoding 'ASCII-8BIT'
          y.yield range
          s += chunk_size
        end

      ensure
        begin
          @redis.del name_tmp
        rescue Redis::BaseConnectionError
          # We have to delete this later if del command failed here,
          # see the beginning of this method.
        end
      end.each(&block)

    rescue Redis::BaseConnectionError => e
      # Maybe it works again later, just log the error…
      @fallback.error(e)
      Enumerator.new {}
    end

    def each(chunk_size: 100 * 1024, &block)
      chunk_size > 0 or raise ArgumentError, 'chunk_size > 0 required'
      Enumerator.new do |y|
        buffer = ''
        buffer.encode! 'ASCII-8BIT'
        each_chunk(chunk_size: chunk_size) do |chunk|
          buffer << chunk
          buffer.gsub!(/\A(.*?#$/)/n) do |line|
            y.yield(line)
            ''
          end
        end
        buffer.length > 0 and y.yield(buffer)
      end.each(&block)
    end
    include Enumerable
  end
end
