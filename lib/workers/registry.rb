module Workers
  class Registry
    def initialize
      @mutex = Mutex.new
      @actors_by_name = {}
    end

    def register(actor)
      @mutex.synchronize do
        return false unless actor.name

        if @actors_by_name[actor.name]
          raise "Actor already exists (#{actor.name})."
        else
          @actors_by_name[actor.name] = actor
        end

        return true
      end
    end

    def unregister(actor)
      @mutex.synchronize do
        return false unless actor.name
        return false unless @actors_by_name[actor.name]

        @actors_by_name.delete(actor.name)

        return true
      end
    end

    def [](val)
      @mutex.synchronize do
        return @actors_by_name[val]
      end
    end

    def dispose
      @mutex.synchronize do
        @actors_by_name.clear
      end
    end
  end
end
