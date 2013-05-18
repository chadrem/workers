module Workers
  class LogProxy
    attr_accessor :logger

    def initialize(logger)
      @logger = logger.is_a?(Workers::LogProxy) ? logger.logger : logger

      return nil
    end

    def debug(msg)
      @logger.debug(msg) if @logger

      return nil
    end

    def info(msg)
      @logger.info(msg) if @logger

      return nil
    end

    def warn(msg)
      @logger.warn(msg) if @logger

      return nil
    end

    def error(msg)
      @logger.error(msg) if @logger

      return nil
    end
  end
end
