# frozen_string_literal: true

REMEMBER_ME_DURATION = 30.days

Clearance.configure do |config|
  config.routes = false
  config.mailer_sender = 'mailer@openhub.net'
  config.password_strategy = PasswordStrategy
  config.secure_cookie = Rails.env.staging? || Rails.env.production?
  config.redirect_url = '/accounts/me'
  config.rotate_csrf_on_sign_in = true
  config.sign_in_guards = [Account::DisabledGuard]
  config.user_model = Account
  config.cookie_expiration = lambda { |cookies|
    cookies[:remember_me] == '1' ? REMEMBER_ME_DURATION.from_now.utc : nil
  }
end
