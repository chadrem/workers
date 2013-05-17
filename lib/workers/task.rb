module Workers
  class Task
    include Workers::Helpers

    attr_reader :args
    attr_reader :result
    attr_reader :exception
    attr_reader :state

    def initialize(options = {})
      @logger = Workers::LogProxy.new(options[:logger])
      @args = options[:args] || []
      @perform = options[:perform] || raise('Perform callback is required.')
      @finished = options[:finished]
      @state = :initialized

      return nil
    end

    def run
      raise "Invalid state (#{@state})." unless @state == :initialized

      @state = :running

      begin
        @result = @perform.call(*@args)
        @state = :succeeded
      rescue Exception => e
        @state = :failed
        @exception = e
      end

      @finished.call(self)

      return nil
    end

    def succeeded?
      return @state == :succeeded
    end

    def failed?
      return @state == :failed
    end
  end
end
