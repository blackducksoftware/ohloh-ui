require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(*Rails.groups)

require 'dotenv'
Dotenv.load '.env.local', ".env.#{Rails.env}"

module OhlohUi
  class Application < Rails::Application
    config.generators.stylesheets = false
    config.generators.javascripts = false
    config.generators.helper = false
    config.action_controller.include_all_helpers = false
    config.active_record.schema_format = :sql
    config.active_record.raise_in_transactional_callbacks = true
    config.action_mailer.default_url_options = { host: ENV['URL_HOST'] }

    config.google_maps_api_key = ENV['GOOGLE_MAPS_API']

    config.autoload_paths << "#{Rails.root}/lib"

    config.to_prepare do
      Doorkeeper::AuthorizationsController.layout 'application'
      Doorkeeper::AuthorizationsController.helper OauthLayoutHelper
    end

    file = "#{Rails.root}/config/GIT_SHA"
    config.git_sha = File.exist?(file) ? File.read(file)[0...40] : 'development'

    matches = /([0-9\.]+)/.match(`passenger -v 2>&1`)
    config.passenger_version = matches ? matches[0] : '???'

    config.cache_store = :redis_store, { host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'],
                                         namespace: ENV['REDIS_NAMESPACE'] }

    config.action_dispatch.default_headers = { 'X-Content-Type-Options' => 'nosniff' }

    # paperclip amazon s3 configurations
    config.paperclip_defaults = {
      storage: :s3,
      s3_credentials: {
        bucket: ENV['OHLOH_S3_BUCKET_NAME'],
        access_key_id: ENV['OHLOH_S3_ACCESS_KEY'],
        secret_access_key: ENV['OHLOH_S3_SECRET_ACCESS_KEY']
      },
      s3_protocol: :https
    }
    Paperclip::Attachment.default_options[:path] = '/attachments/:id/:basename:style.:extension'
    Paperclip::Attachment.default_options[:use_timestamp] = false
  end
end
