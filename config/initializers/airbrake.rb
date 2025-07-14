# frozen_string_literal: true

Airbrake.configure do |config|
  config.environment = Rails.env # must be set for ignore_environments to work
  config.project_key = ENV.fetch('AIRBRAKE_API_KEY', nil)
  config.host = "#{ENV.fetch('AIRBRAKE_HOST', nil)}:#{ENV.fetch('AIRBRAKE_PORT', nil)}"

  config.project_id = ENV.fetch('AIRBRAKE_PROJECT_ID', nil)
  config.ignore_environments = %w[development test]
end

class Airbrake::Sender
  def json_api_enabled?
    true
  end
end
