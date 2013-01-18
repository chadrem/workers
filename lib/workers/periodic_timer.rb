module Workers
  class PeriodicTimer < Workers::Timer
    def initialize(delay, options = {}, callback = nil, &block)
      options[:repeat] = true

      super(delay, options, (callback || block))
    end
  end
end
