# frozen_string_literal: true

Aws.config = {
  access_key_id: ENV.fetch('AWS_SES_ACCESS_KEY', nil),
  secret_access_key: ENV.fetch('AWS_SES_SECRET_ACCESS_KEY', nil),
  region: ENV.fetch('AWS_REGION', nil)
}
