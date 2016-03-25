Airbrake.configure do |config|
  config.project_key = ENV['AIRBRAKE_API_KEY']
  config.host = "#{ENV['AIRBRAKE_HOST']}:#{ENV['AIRBRAKE_PORT'].to_i}"
  config.project_id = ENV['AIRBRAKE_API_KEY']
  config.ignore_environments = %w(development test)
end

class Airbrake::Sender
  def json_api_enabled?
    true
  end
end
