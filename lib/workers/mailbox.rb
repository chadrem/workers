module Workers
  class Mailbox
    def initialize(options = {})
      @messages = []
      @mutex = Mutex.new
    end

    def push(event)
      @mutex.synchronize do
        @messages.push(event)
      end
    end

    def shift
      @mutex.synchronize do
        @messages.shift
      end
    end

    def synchronize(&block)
      @mutex.synchronize do
        block.call
      end
    end
  end
end
