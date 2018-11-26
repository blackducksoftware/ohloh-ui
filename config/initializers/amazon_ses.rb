Aws.config = {
  access_key_id: ENV['AWS_SES_ACCESS_KEY'],
  secret_access_key: ENV['AWS_SES_SECRET_ACCESS_KEY'],
  region: ENV['AWS_REGION']
}
