# frozen_string_literal: true

require File.expand_path('boot', __dir__)
require 'rails/all'

Bundler.require(*Rails.groups)

require 'dotenv'
Dotenv.load '.env.local', ".env.#{Rails.env}"

module OhlohUi
  class Application < Rails::Application
    config.middleware.use Rack::Deflater

    config.generators.stylesheets = false
    config.generators.javascripts = false
    config.generators.helper = false
    config.action_controller.include_all_helpers = false
    config.active_record.schema_format = :sql
    config.active_record.raise_in_transactional_callbacks = true
    config.action_mailer.default_url_options = { host: ENV['URL_HOST'] }
    config.active_job.queue_adapter = :sidekiq

    config.google_maps_api_key = ENV['GOOGLE_MAPS_API']

    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('lib', 'reverification', '**', '*')
    config.autoload_paths << Rails.root.join('lib', 'constraints')

    config.autoload_paths << Rails.root.join('core', '**', '*')
    config.to_prepare do
      Doorkeeper::AuthorizationsController.layout 'application'
      Doorkeeper::AuthorizationsController.helper OauthLayoutHelper
    end

    file = Rails.root.join('config', 'GIT_SHA')
    config.git_sha = File.exist?(file) ? File.read(file)[0...40] : 'development'

    matches = /([0-9\.]+)/.match(`passenger -v 2>&1`)
    config.passenger_version = matches ? matches[0] : '???'

    config.cache_store = :redis_store, { host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'],
                                         namespace: ENV['REDIS_NAMESPACE'] }

    config.action_dispatch.default_headers = { 'X-Content-Type-Options' => 'nosniff' }

    Kaminari.configure do |config|
      config.page_method_name = :per_page_kaminari
    end
  end
end
