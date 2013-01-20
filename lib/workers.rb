require 'thread'
require 'set'

require 'workers/version'
require 'workers/helpers'
require 'workers/worker'
require 'workers/pool'
require 'workers/event'
require 'workers/log_proxy'
require 'workers/scheduler'
require 'workers/timer'
require 'workers/periodic_timer'

module Workers
  def self.pool
    return @pool ||= Workers::Pool.new
  end

  def self.pool=(val)
    @pool.dispose if @pool
    @pool = val
  end

  def self.scheduler
    return @scheduler ||= Workers::Scheduler.new
  end

  def self.scheduler=(val)
    @scheduler.dispose if @scheduler
    @scheduler = val
  end
end

# Force initialization of defaults.
Workers.pool
Workers.scheduler
