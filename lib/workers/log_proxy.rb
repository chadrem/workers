module Workers
  class LogProxy
    attr_accessor :logger

    def initialize(logger)
      @logger = logger.is_a?(Workers::LogProxy) ? logger.logger : logger

      nil
    end

    def debug(msg)
      @logger.debug(msg) if @logger

      nil
    end

    def info(msg)
      @logger.info(msg) if @logger

      nil
    end

    def warn(msg)
      @logger.warn(msg) if @logger

      nil
    end

    def error(msg)
      @logger.error(msg) if @logger

      nil
    end
  end
end
