module Workers
  class Worker
    include Workers::Helpers

    attr_reader :exception

    def initialize(options = {})
      @logger = Workers::LogProxy.new(options[:logger])
      @input_queue = options[:input_queue] || Queue.new
      @thread = Thread.new { start_event_loop }

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
      enqueue(:shutdown, block)

      return nil
    end

    def join(max_wait = nil)
      raise "Worker can't join itself." if @thread == Thread.current

      return true if !@thread.join(max_wait).nil?

      @thread.kill and return false
    end

    def alive?
      return @thread && @thread.alive?
    end

    def inspect
      return "#<#{self.class.to_s}:0x#{(object_id << 1).to_s(16)} #{alive? ? 'alive' : 'dead'}>"
    end

    private

    def start_event_loop
      while true
        event = @input_queue.pop

        case event.command
        when :shutdown
          shutdown_handler(event)
          return nil
        when :perform
          perform_handler(event)
        else
          process_event(event)
        end
      end
    rescue Exception => e
      exception_handler(e)
    end

    def shutdown_handler(event)
      event.data.call(self) if event.data && event.data.is_a?(Proc)
    end

    def perform_handler(event)
      event.data.call
    rescue Exception => e
      exception_handler(e)
    end

    def exception_handler(e)
      @exception = e
    end

    def process_event(event)
      raise ::Workers::UnknownEventError, 'You must override this method to process custom events.'
    rescue Exception => e
      exception_handler(e)
    end
  end
end
