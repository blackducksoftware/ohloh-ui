# frozen_string_literal: true

require File.expand_path('boot', __dir__)
require 'rails/all'

Bundler.require(*Rails.groups)

require 'dotenv'
Dotenv.load '.env.local', ".env.#{Rails.env}"

module OhlohUi
  class Application < Rails::Application
    config.middleware.use Rack::Deflater
    config.load_defaults 6.1

    config.generators.stylesheets = false
    config.generators.javascripts = false
    config.generators.helper = false
    config.action_controller.include_all_helpers = false
    config.active_record.schema_format = :sql
    config.action_mailer.default_url_options = { host: ENV.fetch('URL_HOST', nil) }
    config.active_job.queue_adapter = :sidekiq

    config.google_maps_api_key = ENV.fetch('GOOGLE_MAPS_API', nil)

    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib', 'reverification', '**', '*')
    config.eager_load_paths << Rails.root.join('lib', 'constraints')

    config.eager_load_paths << Rails.root.join('app', 'core', '**', '*')
    config.to_prepare do
      Doorkeeper::AuthorizationsController.layout 'application'
      Doorkeeper::AuthorizationsController.helper OauthLayoutHelper
    end

    file = Rails.root.join('config', 'GIT_SHA')
    config.git_sha = File.exist?(file) ? File.read(file)[0...40] : 'development'

    matches = /([0-9.]+)/.match(`passenger -v 2>&1`)
    config.passenger_version = matches ? matches[0] : '???'

    redis_config = { host: ENV.fetch('REDIS_HOST', nil), port: ENV.fetch('REDIS_PORT', 0).to_i,
                     namespace: ENV.fetch('REDIS_NAMESPACE', nil) }
    redis_config[:password] = ENV.fetch('REDIS_PASSWORD', nil) if Rails.env.development?
    config.cache_store = :redis_store, redis_config
    config.action_dispatch.default_headers = { 'X-Content-Type-Options' => 'nosniff' }
    config.active_record.dump_schemas = :all

    Kaminari.configure do |config|
      config.page_method_name = :per_page_kaminari
    end
  end
end
