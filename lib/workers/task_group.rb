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

      nil
    end

    def add(options = {}, &block)
      state!(:initialized)

      options[:on_finished] = method(:finished)
      options[:on_perform] ||= block

      @tasks << Workers::Task.new(options)

      nil
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

        loop do
          @conditional.wait(@internal_lock)
          # The wait can return even if nothing called @conditional.signal,
          # so we need to check to see if the condition actually changed.
          # See https://github.com/chadrem/workers/issues/7
          break if all_tasks_finished?
        end
      end

      @tasks.all? { |t| t.succeeded? }
    end

    def successes
      @tasks.select { |t| t.succeeded? }
    end

    def failures
      @tasks.select { |t| t.failed? }
    end

    def map(inputs, options = {}, &block)
      inputs.each do |input|
        add(:input => input, :max_tries => options[:max_tries]) do |i|
          block.call(i)
        end
      end

      run

      if (failure = failures[0])
        a = failure.input.inspect
        c = failure.exception.class.to_s
        m = failure.exception.message
        b = failure.exception.backtrace.join("\n")

        raise Workers::FailedTaskError, "#{failures.count} task(s) failed (Only the first failure is shown).\nARGS=#{a}, EXCEPTION=#{c}: #{m}\n#{b}\n----------\n"
      end

      tasks.map { |t| t.result }
    end

    # Convenient mutex to be used by a users's task code that needs serializing.
    # This should NEVER be used by TaskGroup code (use the @internal_lock instead);
    def synchronize(&block)
      @external_lock.synchronize { block.call }

      nil
    end

    private

    def state!(*args)
      unless args.include?(@state)
        raise Workers::InvalidStateError, "Invalid state (#{@state})."
      end

      nil
    end

    def finished(task)
      @internal_lock.synchronize do
        @finished_count += 1
        @conditional.signal if all_tasks_finished?
      end

      nil
    end

    def all_tasks_finished?
      @finished_count >= @tasks.count
    end
  end
end
