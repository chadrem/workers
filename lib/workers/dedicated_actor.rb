module Workers
  class DedicatedActor < Workers::Actor
    def initialize(options = {})
      options[:dedicated] = true

      super(options)
    end
  end
end
