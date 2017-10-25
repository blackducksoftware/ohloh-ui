Rack::Timeout.service_timeout = 20.minutes.to_i

Rack::Timeout::Logger.disable # default logs are not useful to us.

Rack::Timeout.register_state_change_observer(:log_request) do |env|
  if env[Rack::Timeout::ENV_INFO_KEY].state == :timed_out
    request = Rack::Request.new(env)

    logger = Logger.new(Rails.root.join('log', 'timeout.log'))
    logger.info(request.fullpath)
    logger.close
  end
end
