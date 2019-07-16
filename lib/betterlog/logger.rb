require 'redis'

module Betterlog
  class Logger < ::Logger
    def initialize(redis, shift_age = 0, shift_size = 1048576, name: nil, **opts)
      @redis = redis
      @name  = name || self.class.name
      super(@logdev, shift_age, shift_size, **opts)
    end

    private def redis_write(msg)
      # Redis string limit is at 512MB, stop before that after warning a lot.
      if @redis.strlen(@name) > 511 * 1024 ** 2
        return nil
      end
      if @redis.strlen(@name) > 510 * 1024 ** 2
        @redis.append @name, "\nRedis memory limit will soon be reached =>"\
          " Log output to redis stops now unless log data is pushed away!\n"
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
    end

    def <<(msg)
      redis_write(msg)
    end

    def clear
      @redis.del @name
      self
    end

    def each_chunk(chunk_size: 100 * 1024, &block)
      chunk_size > 0 or raise ArgumentError, 'chunk_size > 0 required'
      @redis.exists(@name) or return Enumerator.new {}
      Enumerator.new do |y|
        name_tmp = "#{@name}_#{rand}"
        @redis.rename @name, name_tmp
        s = 0
        e = @redis.strlen(name_tmp) - 1
        until s > e
          y.yield @redis.getrange(name_tmp, s, s + chunk_size - 1)
          s += chunk_size
        end
        @redis.del name_tmp
      end.each(&block)
    end

    def each(chunk_size: 100 * 1024, &block)
      chunk_size > 0 or raise ArgumentError, 'chunk_size > 0 required'
      Enumerator.new do |y|
        buffer = ''
        each_chunk(chunk_size: chunk_size) do |chunk|
          buffer << chunk
          buffer.gsub!(/\A(.*?#$/)/) do |line|
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