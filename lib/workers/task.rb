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
      @on_perform = options[:on_perform] || raise(Workers::MissingCallbackError, 'on_perform callback is required.')
      @on_finished = options[:on_finished]
      @max_tries = options[:max_tries] || 1
      @state = :initialized
      @tries = 0

      raise Workers::MaxTriesError, 'max_tries must be >= 1' unless @max_tries >= 1

      nil
    end

    def run
      raise Workers::InvalidStateError, "Invalid state (#{@state})." unless @state == :initialized

      @state = :running

      while(@tries < @max_tries && @state != :succeeded)
        @tries += 1

        begin
          @result = @on_perform.call(@input)
          @state = :succeeded
          @exception = nil
        rescue Exception => e
          @state = :failed
          @exception = e
        end
      end

      @on_finished.call(self)

      nil
    end

    def succeeded?
      @state == :succeeded
    end

    def failed?
      @state == :failed
    end
  end
end
