Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY']
  config.host    = ENV['AIRBRAKE_HOST']
  config.port    = ENV['AIRBRAKE_PORT'].to_i
  config.secure  = false
  config.project_id = ENV['AIRBRAKE_API_KEY']
end

class Airbrake::Sender
  def json_api_enabled?
    true
  end
end
