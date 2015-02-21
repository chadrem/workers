require 'thread'
require 'monitor'
require 'set'

require 'workers/version'
require 'workers/helpers'
require 'workers/worker'
require 'workers/pool'
require 'workers/event'
require 'workers/log_proxy'
require 'workers/scheduler'
require 'workers/bucket_scheduler'
require 'workers/timer'
require 'workers/periodic_timer'
require 'workers/task'
require 'workers/task_group'

module Workers
  def self.pool
    lock do
      return @pool ||= Workers::Pool.new
    end
  end

  def self.pool=(val)
    lock do
      @pool.dispose if @pool
      @pool = val
    end
  end

  def self.scheduler
    lock do
      return @scheduler ||= Workers::Scheduler.new
    end
  end

  def self.scheduler=(val)
    lock do
      @scheduler.dispose if @scheduler
      @scheduler = val
    end
  end

  def self.map(inputs, options = {}, &block)
    return Workers::TaskGroup.new.map(inputs, options) do |i|
      yield(i)
    end
  end

  def self.lock(&block)
    (@lock ||= Monitor.new).synchronize { yield if block_given? }
  end
end

# Force initialization of defaults.
Workers.lock
