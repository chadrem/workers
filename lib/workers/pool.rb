module Workers
  class Pool
    include Workers::Helpers

    DEFAULT_POOL_SIZE = 20

    def initialize(options = {})
      @logger = Workers::LogProxy.new(options[:logger])
      @worker_class = options[:worker_class] || Workers::Worker
      @input_queue = Queue.new
      @lock = Monitor.new
      @workers = Set.new
      @size = 0
      @exception_callback = options[:on_exception]

      expand(options[:size] || Workers::Pool::DEFAULT_POOL_SIZE)

      return nil
    end

    def enqueue(command, data = nil)
      @input_queue.push(Event.new(command, data))

      return nil
    end

    def perform(&block)
      e_callback = @exception_callback

      safe_block = proc {
        begin
          block.call
        rescue Exception => e
          e_callback.call(e) if e_callback
        end
      }

      enqueue(:perform, safe_block)

      return nil
    end

    def shutdown(&block)
      @lock.synchronize do
        @size.times do
          enqueue(:shutdown, block)
        end
      end

      return nil
    end

    def join(max_wait = nil)
      results = @workers.map { |w| w.join(max_wait) }
      @workers.clear
      @size = 0

      return results
    end

    def dispose(max_wait = nil)
      @lock.synchronize do
        shutdown
        return join(max_wait)
      end
    end

    def inspect
      return "#<#{self.class.to_s}:0x#{(object_id << 1).to_s(16)} size=#{size}>"
    end

    def size
      @lock.synchronize do
        return @size
      end
    end

    def expand(count)
      @lock.synchronize do
        count.times do
            @workers << @worker_class.new(:input_queue => @input_queue)
            @size += 1
        end
      end

      return nil
    end

    def contract(count, &block)
      @lock.synchronize do
        raise Workers::PoolSizeError, 'Count is too large.' if count > @size

        count.times do
          callback = Proc.new do |worker|
            remove_worker(worker)
            block.call if block
          end

          enqueue(:shutdown, callback)
          @size -= 1
        end
      end

      return nil
    end

    def resize(new_size)
      @lock.synchronize do
        if new_size > @size
          expand(new_size - @size)
        elsif new_size < @size
          contract(@size - new_size)
        end
      end

      return nil
    end

    private

    def remove_worker(worker)
      @lock.synchronize do
        @workers.delete(worker)
      end

      return nil
    end
  end
end
