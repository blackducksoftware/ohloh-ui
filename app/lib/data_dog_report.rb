# frozen_string_literal: true

module DataDogReport
  module_function

  def info(message)
    Logger.new(ENV.fetch('DATADOG_LOGGER_PATH', nil)).info(message)
  end

  def error(message)
    Rails.logger.error message
  end
end
