# frozen_string_literal: true

Airbrake.configure do |config|
  config.environment = Rails.env # must be set for ignore_environments to work
  config.project_key = ENV['AIRBRAKE_API_KEY']
  config.host = "#{ENV['AIRBRAKE_HOST']}:#{ENV['AIRBRAKE_PORT'].to_i}"
  config.project_id = ENV['AIRBRAKE_PROJECT_ID']
  config.ignore_environments = %w[development test]
end

class Airbrake::Sender
  def json_api_enabled?
    true
  end
end
