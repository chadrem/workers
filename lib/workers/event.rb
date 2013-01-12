module Workers
  class Event
    attr_accessor :command
    attr_accessor :data

    def initialize(command, data)
      @command = command
      @data = data
    end
  end
end
