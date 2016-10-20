require 'aws-sdk'
Aws.config.update({
  region: ENV['AWS_REGION'],
  credentials: Aws::Credentials.new(ENV['AWS_SES_ACCESS_KEY'], ENV['AWS_SES_SECRET_ACCESS_KEY'])
})
