# frozen_string_literal: true

Clearance.configure do |config|
  config.routes = false
  config.mailer_sender = 'mailer@openhub.net'
  config.password_strategy = PasswordStrategy
  config.redirect_url = '/accounts/me'
  config.rotate_csrf_on_sign_in = true
  config.sign_in_guards = [Account::DisabledGuard]
  config.user_model = Account
  config.cookie_expiration = -> (cookies) do
    (ENV['EXPIRATION_DAYS'].to_i).days.from_now
  end
end
