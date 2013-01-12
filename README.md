# Workers

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'workers'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install workers

## Usage

    # Initialize a worker pool.
    pool = Workers::Pool.new
    
    # Perform some work in the background.
    100.times do
      pool.perform do
        sleep(rand(3))
        puts "Hello World from thread #{Thread.current.object_id}"
      end
    end
    
    # Tell the workers to shutdown.
    pool.shutdown do
      puts "worker thread #{Thread.current.object_id} is shutting down."
    end
    
    # Wait for the workers to finish.
    pool.join

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
