module Workers
  class Timer
    include Workers::Helpers

    attr_reader :delay
    attr_reader :repeat

    def initialize(delay, options = {}, &block)
      @logger = Workers::LogProxy.new(options[:logger])
      @delay = delay
      @callback = options[:callback] || block
      @repeat = options[:repeat] || false
      @scheduler = options[:scheduler] || Workers.scheduler
      @mutex = Mutex.new

      reset
      @scheduler.schedule(self)

      return nil
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
        @callback.call if @callback
      end

      return nil
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
