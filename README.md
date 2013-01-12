# Workers

Workers is a Ruby gem for performing work in background threads.
Design goals include high performance, low latency, simple API, and customizability.

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
    
    # Wait for the workers to finish.
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
    
    # Wait for it to finish working and shutdown.
    pool.join
    
## Pool Options

The pool class takes a few options (defaults below):

    pool = Workers::Pool.new(
      :size => 20,                     # Number of threads to create.
      :logger => nil                   # Ruby Logger instance.
      :worker_class => Workers::Worker # Class of worker to create for this pool.
    
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
