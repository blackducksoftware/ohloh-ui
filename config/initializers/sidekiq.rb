# frozen_string_literal: true

Sidekiq.configure_server do |config|
  redis_config = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/0" }
  redis_config[:password] = ENV['REDIS_PASSWORD'] if Rails.env.development?
  redis_config[:id] = nil
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  redis_config = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/0" }
  redis_config[:password] = ENV['REDIS_PASSWORD'] if Rails.env.development?
  redis_config[:id] = nil
  config.redis = redis_config
end
