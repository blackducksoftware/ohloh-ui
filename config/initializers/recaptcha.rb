Recaptcha.configure do |config|
  config.public_key = '6Lch7woTAAAAAG_gSMX70RXBIxoatpetPNPBy5ob'
  config.private_key = ENV['RECAPTCHA_SECRET_KEY']
  config.api_version = 'v2'
end
