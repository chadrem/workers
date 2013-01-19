module Workers
  class Pool
    include Workers::Helpers

    DEFAULT_POOL_SIZE = 20

    def initialize(options = {})
      @logger = Workers::LogProxy.new(options[:logger])
      @size = options[:size] || Workers::Pool::DEFAULT_POOL_SIZE
      @worker_class = options[:worker_class] || Workers::Worker

      @input_queue = Queue.new
      @workers = []
      @size.times { @workers << @worker_class.new(:input_queue => @input_queue) }
    end

    def enqueue(command, data)
      @input_queue.push(Event.new(command, data))

      return nil
    end

    def perform(&block)
      enqueue(:perform, block)

      return nil
    end

    def shutdown(&block)
      @size.times { enqueue(:shutdown, block) }

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
  end
end
