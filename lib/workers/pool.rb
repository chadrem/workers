module Workers
  class Pool
    include Workers::Helpers

    DEFAULT_POOL_SIZE = 20

    attr_accessor :on_exception

    def initialize(options = {})
      @logger = Workers::LogProxy.new(options[:logger])
      @worker_class = options[:worker_class] || Workers::Worker
      @input_queue = Queue.new
      @lock = Monitor.new
      @workers = Set.new
      @size = 0
      @on_exception = options[:on_exception]

      expand(options[:size] || Workers::Pool::DEFAULT_POOL_SIZE)

      nil
    end

    def enqueue(command, data = nil)
      @input_queue.push(Event.new(command, data))

      nil
    end

    def perform(&block)
      enqueue(:perform, block)

      nil
    end

    def shutdown(&block)
      @lock.synchronize do
        @size.times do
          enqueue(:shutdown, block)
        end
      end

      nil
    end

    def join(max_wait = nil)
      results = @workers.map { |w| w.join(max_wait) }
      @workers.clear
      @size = 0

      results
    end

    def dispose(max_wait = nil, &block)
      shutdown do
        block.call if block
      end

      join(max_wait)
    end

    def inspect
      "#<#{self.class.to_s}:0x#{(object_id << 1).to_s(16)} size=#{size}>"
    end

    def size
      @lock.synchronize do
        @size
      end
    end

    def expand(count)
      @lock.synchronize do
        count.times do
          worker = @worker_class.new(:input_queue => @input_queue, :on_exception => @on_exception, :logger => @logger)
          @workers << worker
          @size += 1
        end
      end

      nil
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

      nil
    end

    def resize(new_size)
      @lock.synchronize do
        if new_size > @size
          expand(new_size - @size)
        elsif new_size < @size
          contract(@size - new_size)
        end
      end

      nil
    end

    private

    def remove_worker(worker)
      @lock.synchronize do
        @workers.delete(worker)
      end

      nil
    end
  end
end
