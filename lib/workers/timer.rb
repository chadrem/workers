module Workers
  class Timer
    def initialize(delay, options = {}, &block)
      @delay = delay
      @callback = block

      @fired = false
      @fire_at = Time.now.utc + delay
      @mutex = Mutex.new

      (options[:scheduler] || Workers.scheduler).schedule(self)
    end

    def <=>(other)
      return sec_remaining <=> other.sec_remaining
    end

    def sec_remaining
      @mutex.synchronize do
        diff = @fire_at.to_f - Time.now.utc.to_f

        return (diff > 0) ? diff : 0
      end
    end

    def overdue?
        return sec_remaining <= 0
    end

    def fired?
      @mutex.synchronize do
        return @fired
      end
    end

    def fire
      @mutex.synchronize do
        return false if @fired

        begin
          @fired = true
          @callback.call
        rescue Exception => e
          puts "EXCEPTION: #{e.message}\n#{e.backtrace.join("\n")}\n--"
        end

        return true
      end
    end
  end
end
