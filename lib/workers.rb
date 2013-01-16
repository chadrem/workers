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

module Workers
  def self.scheduler
    return @scheduler ||= Workers::Scheduler.new
  end
end

Workers.scheduler # Force initialization of default scheduler.
