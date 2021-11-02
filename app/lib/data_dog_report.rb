# frozen_string_literal: true

module DataDogReport
  module_function

  def error(message)
    request = DatadogAPIClient::V1::EventCreateRequest.new(text: message, title: "OpenHub #{Rails.env} Error",
                                                           alert_type: :error, date_happened: Time.current.to_i,
                                                           host: ENV['HOSTNAME'])
    api_instance.create_event(request)
  end

  def api_instance
    DatadogAPIClient::V1::EventsAPI.new
  end
end
