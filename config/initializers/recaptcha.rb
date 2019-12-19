# frozen_string_literal: true

Recaptcha.configure do |config|
  config.site_key = ENV['RECAPTCHA_PUBLIC_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
end
