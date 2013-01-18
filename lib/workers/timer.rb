module Workers
  class Timer
    attr_reader :delay
    attr_reader :repeat

    def initialize(delay, options = {}, &block)
      @delay = delay
      @callback = options[:callback] || block
      @repeat = options[:repeat] || false
      @scheduler = options[:scheduler] || Workers.scheduler
      @logger = options[:logger]

      @mutex = Mutex.new

      reset

      @scheduler.schedule(self)
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

    def fire
      @mutex.synchronize do
        begin
          @callback.call if @callback
        rescue Exception => e
        end

        return nil
      end
    end

    def cancel
      @scheduler.unschedule(self)

      return nil
    end

    def reset
      @mutex.synchronize do
        @fire_at = Time.now.utc + @delay
      end

      return nil
    end
  end
end
