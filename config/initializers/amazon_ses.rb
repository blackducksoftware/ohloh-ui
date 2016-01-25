AWS.config(
  :access_key_id => ENV['AMAZON_SES_ACCESS_KEY'],
  :secret_access_key => ENV['AMAZON_SES_SECRET_ACCESS_KEY'],
  :region => ENV['AWS_REGION'])