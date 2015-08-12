Recaptcha.configure do |config|
  config.public_key = '6Lc4IgsTAAAAAD_aMrJhr8o9zg8rl5yZcmZB5OiW'
  config.private_key = ENV['RECAPTCHA_SECRET_KEY']
  config.api_version = 'v2'
end
