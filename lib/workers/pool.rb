module Workers
  class Pool
    include Workers::Helpers

    DEFAULT_POOL_SIZE = 20

    def initialize(options = {})
      @logger = Workers::LogProxy.new(options[:logger])
      @worker_class = options[:worker_class] || Workers::Worker

      @input_queue = Queue.new
      @workers = []
      @size = 0

      expand(options[:size] || Workers::Pool::DEFAULT_POOL_SIZE)

      return nil
    end

    def enqueue(command, data = nil)
      @input_queue.push(Event.new(command, data))

      return nil
    end

    def perform(&block)
      enqueue(:perform, block)

      return nil
    end

    def shutdown(&block)
      contract(@size, block)

      return nil
    end

    def join(max_wait = nil)
      return @workers.map { |w| w.join(max_wait) }
    end

    def dispose
      shutdown
      join

      return nil
    end

    def inspect
      return "#<#{self.class.to_s}:0x#{(object_id << 1).to_s(16)} size=#{@size}>"
    end

    def size
      return @size
    end

    def expand(count)
      count.times do
        @workers << @worker_class.new(:input_queue => @input_queue)
        @size += 1
      end

      return nil
    end

    def contract(count, &block)
      raise 'Count is too large.' if count > @size

      count.times do
        enqueue(:shutdown, block)
        @size -= 1
      end

      return nil
    end
  end
end
