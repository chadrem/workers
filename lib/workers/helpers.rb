module Workers
  module Helpers
    def log_debug(msg, e = nil)
      (@_logger || @logger).debug(concat_e(msg, e))
    end

    def log_info(msg, e = nil)
      (@_logger || @logger).info(concat_e(msg, e))
    end

    def log_warn(msg, e = nil)
      (@_logger || @logger).warn(concat_e(msg, e))
    end

    def log_error(msg, e = nil)
      (@_logger || @logger).error(concat_e(msg, e))
    end

    def concat_e(msg, e = nil)
      return e ? "#{msg}\nEXCEPTION: #{e.message}\n#{e.backtrace.join("\n")}\n--" : msg
    end
  end
end
