module Workers
  class Task
    include Workers::Helpers

    attr_reader :input
    attr_reader :result
    attr_reader :exception
    attr_reader :state
    attr_reader :max_tries
    attr_reader :tries

    def initialize(options = {})
      @logger = Workers::LogProxy.new(options[:logger])
      @input = options[:input] || []
      @perform = options[:perform] || raise('Perform callback is required.')
      @finished = options[:finished]
      @max_tries = options[:max_tries] || 1
      @state = :initialized
      @tries = 0

      raise 'max_tries must be >= 1' unless @max_tries >= 1

      return nil
    end

    def run
      raise "Invalid state (#{@state})." unless @state == :initialized

      @state = :running

      while(@tries < @max_tries && @state != :succeeded)
        @tries += 1

        begin
          @result = @perform.call(@input)
          @state = :succeeded
          @exception = nil
        rescue Exception => e
          @state = :failed
          @exception = e
        end
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
