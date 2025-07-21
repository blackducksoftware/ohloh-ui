# frozen_string_literal: true

Sidekiq.configure_server do |config|
  redis_config = { url: "redis://#{ENV.fetch('REDIS_HOST', nil)}:#{ENV.fetch('REDIS_PORT', nil)}/0" }
  redis_config[:password] = ENV.fetch('REDIS_PASSWORD', nil) if Rails.env.development?
  redis_config[:id] = nil
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  redis_config = { url: "redis://#{ENV.fetch('REDIS_HOST', nil)}:#{ENV.fetch('REDIS_PORT', nil).to_i}/0" }
  redis_config[:password] = ENV.fetch('REDIS_PASSWORD', nil) if Rails.env.development?
  redis_config[:id] = nil
  config.redis = redis_config
end
