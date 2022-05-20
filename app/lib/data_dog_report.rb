# frozen_string_literal: true

# rubocop:disable Rails/Output

module DataDogReport
  module_function

  def error(message)
    if ENV['KUBERNETES_PORT']
      puts message
    else
      request = DatadogAPIClient::V1::EventCreateRequest.new(text: message.truncate(4000),
                                                             title: "OpenHub #{Rails.env} Error",
                                                             alert_type: :error, date_happened: Time.current.to_i,
                                                             host: ENV['HOSTNAME'])
      api_instance.create_event(request)
    end
  end

  def api_instance
    DatadogAPIClient::V1::EventsAPI.new
  end
end
# rubocop:enable Rails/Output
