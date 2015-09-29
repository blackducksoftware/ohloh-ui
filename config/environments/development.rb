Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.delivery_method = :letter_opener
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

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
