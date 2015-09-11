module Workers
  class Worker
    include Workers::Helpers

    attr_accessor :exception

    def initialize(options = {})
      @logger = Workers::LogProxy.new(options[:logger])
      @input_queue = options[:input_queue] || Queue.new
      @thread = Thread.new { start_event_loop }
      @exception_callback = options[:on_exception]
      @die_on_exception = options.include?(:die_on_exception) ? options[:die_on_exception] : true
      @run = true

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
      enqueue(:shutdown, block)

      nil
    end

    def kill
      @thread.kill

      nil
    end

    def join(max_wait = nil)
      raise Workers::JoinError, "Worker can't join itself." if @thread == Thread.current

      return true if !@thread.join(max_wait).nil?

      @thread.kill and return false
    end

    def dispose(max_wait = nil)
      shutdown
      join(max_wait)
    end

    def alive?
      @thread && @thread.alive?
    end

    def inspect
      "#<#{self.class.to_s}:0x#{(object_id << 1).to_s(16)} #{alive? ? 'alive' : 'dead'}>"
    end

    private

    def start_event_loop
      while @run
        process_event
      end
    end

    def process_event
      event = @input_queue.pop
      event_handler(event)
    rescue Exception => e
      exception_handler(e)
    end

    # Override this method to handle custom events.
    # Make sure you call super(event) if want to built-in events to work.
    def event_handler(event)
      case event.command
      when :shutdown
        shutdown_handler(event)
        @run = false
      when :perform
        perform_handler(event)
      else
        raise Workers::UnknownEventError, "Unhandled event (#{event.inspect})."
      end

      nil
    end

    def shutdown_handler(event)
      event.data.call(self) if event.data

      nil
    end

    def perform_handler(event)
      event.data.call

      nil
    end

    def exception_handler(e)
      @exception = e
      @exception_callback.call(e) if @exception_callback
      raise(e) if @die_on_exception

      nil
    end
  end
end
