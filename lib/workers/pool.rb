module Workers
  class Pool
    include Workers::Helpers

    DEFAULT_POOL_SIZE = 20

    def initialize(options = {})
      @size = options[:size] || Workers::Pool::DEFAULT_POOL_SIZE
      @logger = Workers::LogProxy.new(options[:logger])
      @worker_class = options[:worker_class] || Workers::Worker

      @input_queue = Queue.new
      @workers = []
      @size.times { @workers << @worker_class.new(:input_queue => @input_queue) }
    end

    def enqueue(command, data)
      @input_queue.push(Event.new(command, data))

      return nil
    end

    def perform(options = {}, &block)
      enqueue(:perform, block)

      return nil
    end

    def shutdown(options = {}, &block)
      @size.times { enqueue(:shutdown, block) }

      return nil
    end

    def join(max_wait = nil)
      return @workers.map { |w| w.join(max_wait) }
    end
  end
end
