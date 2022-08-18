# frozen_string_literal: true

module DataDogReport
  module_function

  def error(message)
    Rails.logger.error message
  end
end
