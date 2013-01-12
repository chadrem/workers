module Workers
  class Pool
    include Workers::Helpers

    DEFAULT_POOL_SIZE = 20

    def initialize(options = {})
      @size = options[:size] || Workers::Pool::DEFAULT_POOL_SIZE
      @logger = Workers::LogProxy.new(options[:logger])
      @input_queue = Queue.new
      @workers = []
      @size.times { @workers << Workers::Worker.new(:input_queue => @input_queue) }
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

    private

    def enqueue(command, data)
      @input_queue.push(Event.new(command, data))
    end
  end
end
