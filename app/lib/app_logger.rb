# frozen_string_literal: true

module AppLogger
  module_function

  def logger
    @logger ||= Logger.new(ENV.fetch('APP_LOGGER_PATH', nil))
  end

  def info(message)
    logger.info(message)
  end

  def error(message)
    logger.error(message)
  end
end
