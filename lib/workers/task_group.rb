module Workers
  class TaskGroup
    include Workers::Helpers

    attr_reader :state
    attr_reader :tasks

    def initialize(options = {})
      @logger = Workers::LogProxy.new(options[:logger])
      @pool = options[:pool] || Workers.pool
      @state = :initialized
      @tasks = []
      @internal_lock = Mutex.new
      @external_lock = Mutex.new
      @finished_count = 0
      @conditional = ConditionVariable.new

      return nil
    end

    def add(options = {}, &block)
      state!(:initialized)

      options[:finished] = method(:finished)
      options[:perform] ||= block

      @tasks << Workers::Task.new(options)

      return nil
    end

    def run
      state!(:initialized)

      @state = :running
      @run_thread = Thread.current

      return [] if @tasks.empty?

      @internal_lock.synchronize do
        @tasks.each do |task|
          @pool.perform { task.run }
        end

        @conditional.wait(@internal_lock)
      end

      return @tasks.all? { |t| t.succeeded? }
    end

    def successes
      return @tasks.select { |t| t.succeeded? }
    end

    def failures
      return @tasks.select { |t| t.failed? }
    end

    def map(inputs, &block)
      inputs.each do |input|
        add(:args => input) do |i|
          block.call(i)
        end
      end

      run

      if (failure = failures[0])
        a = failure.args.inspect
        m = failure.exception.message
        b = failure.exception.backtrace.join("\n")

        raise "At least one task failed. ARGS=#{a}, TRACE=#{m}\n#{b}\n----------\n"
      end

      return tasks.map { |t| t.result }
    end

    # Convenient mutex to be used by a users's task code that needs serializing.
    # This should NEVER be used by TaskGroup code (use the @internal_lock instead);
    def synchronize(&block)
      @external_lock.synchronize { block.call }

      return nil
    end

    private

    def state!(*args)
      unless args.include?(@state)
        raise "Invalid state (#{@state})."
      end

      return nil
    end

    def finished(task)
      @internal_lock.synchronize do
        @finished_count += 1
        @conditional.signal if @finished_count >= @tasks.count
      end

      return nil
    end
  end
end
