# frozen_string_literal: true

Sidekiq.configure_server do |config|
  redis_config = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/0" }
  redis_config[:password] = ENV['REDIS_PASSWORD'] unless ENV['KUBERNETES_PORT']
  redis_config[:id] = nil if ENV['KUBERNETES_PORT']
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  redis_config = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/0" }
  redis_config[:password] = ENV['REDIS_PASSWORD'] unless ENV['KUBERNETES_PORT']
  redis_config[:id] = nil if ENV['KUBERNETES_PORT']
  config.redis = redis_config
end
