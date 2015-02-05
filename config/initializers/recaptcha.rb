Recaptcha.configure do |config|
  config.public_key = '6LcuzgATAAAAAIRlxDTWNTcqhDbzAkAFkDWeR8n5'
  config.private_key = ENV['RECAPTCHA_SECRET_KEY']
  config.api_version = 'v2'
end
