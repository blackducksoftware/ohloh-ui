# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

Rails.application.configure do
  # paperclip amazon s3 configurations
  config.paperclip_defaults = {
    storage: :s3,
    s3_credentials: {
      bucket: ENV.fetch('OHLOH_S3_BUCKET_NAME', nil),
      access_key_id: ENV.fetch('OHLOH_S3_ACCESS_KEY', nil),
      secret_access_key: ENV.fetch('OHLOH_S3_SECRET_ACCESS_KEY', nil)
    },
    s3_region: ENV.fetch('AWS_REGION', nil),
    s3_protocol: :https,
    s3_host_name: "s3.#{ENV.fetch('AWS_REGION', nil)}.amazonaws.com",
    url: ':s3_domain_url',
    endpoint: "https://s3.#{ENV.fetch('AWS_REGION', nil)}.amazonaws.com"
  }
end

# Initialize the Rails application.
Rails.application.initialize!
