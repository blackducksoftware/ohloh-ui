# frozen_string_literal: true

# Load the Rails application.
require File.expand_path('application', __dir__)

Rails.application.configure do
  # paperclip amazon s3 configurations
  config.paperclip_defaults = {
    storage: :s3,
    s3_credentials: {
      bucket: ENV['OHLOH_S3_BUCKET_NAME'],
      access_key_id: ENV['OHLOH_S3_ACCESS_KEY'],
      secret_access_key: ENV['OHLOH_S3_SECRET_ACCESS_KEY']
    },
    s3_region: ENV['AWS_REGION'],
    s3_protocol: :https
  }
end

# Initialize the Rails application.
Rails.application.initialize!
