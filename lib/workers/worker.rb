module Workers
  class Worker
    include Workers::Helpers

    def initialize(options = {})
      @logger = Workers::LogProxy.new(options[:logger])
      @input_queue = options[:input_queue] || Queue.new

      @thread = Thread.new { start_event_loop }
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
      enqueue(:shutdown, block)

      return nil
    end

    def join(max_wait = nil)
      raise "Worker can't join itself!" if @thread == Thread.current

      return true if !@thread.join(max_wait).nil?

      @thread.kill and return false
    end

    private

    def start_event_loop
      while true
        event = @input_queue.pop # Blocking.

        case event.command
        when :shutdown
          try_callback(event.data) do |e|
            log_error("Worker failed run 'shutdown' callback.", e)
          end
          return
        when :perform
          try_callback(event.data) do |e|
            log_error("Worker failed run 'perform' callback.", e)
          end
        else
          process_event(event)
        end
      end
    end

    def try_callback(callback, &block)
      begin
        callback.call
      rescue Exception => e
        block.call(e)
      end
    end

    def process_event(event)
      raise 'Subclass and override if you need custom commands.'
    end
  end
end
