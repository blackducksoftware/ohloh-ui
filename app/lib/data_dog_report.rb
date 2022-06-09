# frozen_string_literal: true

# rubocop:disable Rails/Output

module DataDogReport
  module_function

  def error(message)
    puts message
  end

  def api_instance
    DatadogAPIClient::V1::EventsAPI.new
  end
end
# rubocop:enable Rails/Output
