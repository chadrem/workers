module Workers
  class LogProxy
    attr_accessor :logger

    def initialize(logger)
      @logger = logger
    end

    def debug(msg)
      @logger.debug(msg) if @logger
    end

    def info(msg)
      @logger.info(msg) if @logger
    end

    def warn(msg)
      @logger.warn(msg) if @logger
    end

    def error(msg)
      @logger.error(msg) if @logger
    end
  end
end
