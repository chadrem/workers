module Workers
  class Scheduler
    def initialize(options = {})
      @pool = options[:pool] || Workers::Pool.new
      @schedule = SortedSet.new
      @mutex = Mutex.new
      @thread = Thread.new { start_loop }
    end

    def schedule(timer)
      @mutex.synchronize do
        @schedule << timer
      end

      wakeup

      return true
    end

    def wakeup
      @thread.wakeup

      return true
    end

    def dispose
      @mutex.synchronize do
        @pool.shutdown
        @pool.join
        @thread.kill
      end

      return true
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
    rescue Exception => e
      puts e.inspect
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
      end

      return nil
    end

    def next_delay
      @schedule.first ? @schedule.first.sec_remaining : nil
    end
  end
end
