# Workers

Workers is a Ruby gem for performing work in background threads.
Design goals include high performance, low latency, simple API, and customizability, and multi-layered architecture.

## Installation

Add this line to your application's Gemfile:

    gem 'workers'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install workers

## Basic Usage

    # Initialize a worker pool.
    pool = Workers::Pool.new

    # Perform some work in the background.
    100.times do
      pool.perform do
        sleep(rand(3))
        puts "Hello world from thread #{Thread.current.object_id}"
      end
    end

    # Tell the workers to shutdown.
    pool.shutdown do
      puts "Worker thread #{Thread.current.object_id} is shutting down."
    end

    # Wait for the workers to shutdown.
    pool.join

## Advanced Usage

The Worker class is designed to be customized.

    # Create a custom worker class that handles custom commands.
    class CustomWorker < Workers::Worker
      private
      def process_event(event)
        case event.command
        when :my_custom
          puts "Worker received custom event: #{event.data}"
          sleep(1)
        end
      end
    end

    # Create a pool that uses your custom worker class.
    pool = Workers::Pool.new(:worker_class => CustomWorker)

    # Tell the workers to do some work using custom events.
    100.times do |i|
      pool.enqueue(:my_custom, i)
    end

    # Tell the workers to shutdown.
    pool.shutdown do
      puts "Worker thread #{Thread.current.object_id} is shutting down."
    end

    # Wait for the workers to shutdown.
    pool.join

## Options

The pool class (defaults below):

    pool = Workers::Pool.new(
      :size => 20,                     # Number of threads to create.
      :logger => nil,                  # Ruby Logger instance.
      :worker_class => Workers::Worker # Class of worker to use for this pool.
    )

The worker class (defaults below):

    worker = Workers::Worker.new(
      :logger => nil,                  # Ruby Logger instance.
      :input_queue => nil              # Ruby Queue used for input events.
    )

## TODO

Currently, the Workers gem has event driven workers and thread pooling.
Using these building blocks I intend to create higher classes called TaskGroup and Task.
Below is a prototype design (not yet implemented):

    # Create a task group (it contains a pool of workers).
    group = Workers::TaskGroup.new

    # Add tasks to the group.
    100.times do |i|
      group.add(i) do
        i * i
      end
    end

    # Execute the tasks (blocks until the tasks complete).
    group.run

    # Review the results.
    group.tasks.each do |t|
      t.succeeded? # True or false (false if an exception occurred).
      t.args       # Input arguments (the value of i in this example).
      t.result     # Output value (the result of i * i in this example).
      t.exception  # The exception if one exists.
    end

TaskGroup and Task can then be used to build an easy to use parallel map.
Care will have to taken regarding global data and the thread safety of data structures:

    Workers.map([1, 2, 3, 4]) { |i| i * i }

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
