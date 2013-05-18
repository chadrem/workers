module Workers
  class PeriodicTimer < Workers::Timer
    def initialize(delay, options = {}, &block)
      options[:repeat] = true

      super(delay, options, &block)

      return nil
    end
  end
end
