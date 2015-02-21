module Workers
  class Scheduler
    include Workers::Helpers

    def initialize(options = {})
      @logger = Workers::LogProxy.new(options[:logger])
      @pool = options[:pool] || Workers::Pool.new
      @schedule = SortedSet.new
      @mutex = Mutex.new
      @thread = Thread.new { start_loop }

      return nil
    end

    def schedule(timer)
      @mutex.synchronize do
        @schedule << timer
      end

      wakeup

      return nil
    end

    def unschedule(timer)
      @mutex.synchronize do
        @schedule.delete(timer)
      end

      return nil
    end

    def wakeup
      @thread.wakeup

      return nil
    end

    def dispose
      @mutex.synchronize do
        @pool.shutdown
        @pool.join
        @thread.kill
      end

      return nil
    end

    def alive?
      return @thread && @thread.alive?
    end

    private

    def start_loop
      while true
        delay = nil

        @mutex.synchronize do
          process_overdue
          delay = next_delay
        end

        delay ? sleep(delay) : sleep
      end

      return nil
    end

    def process_overdue
      overdue = []

      while @schedule.first && @schedule.first.overdue?
        overdue << @schedule.first
        @schedule.delete(@schedule.first)
      end

      overdue.each do |timer|
        @pool.perform do
          timer.fire
        end

        timer.reset
        @schedule << timer if timer.repeat
      end

      return nil
    end

    def next_delay
      @schedule.first ? @schedule.first.sec_remaining : nil
    end
  end
end
