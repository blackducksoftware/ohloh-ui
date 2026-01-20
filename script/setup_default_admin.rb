# frozen_string_literal: true

require_relative '../config/environment'

login = ARGV[0] || :admin_user
password = ARGV[1] || :admin_password
email = ARGV[2] || 'admin@example.com'

account = Account.create!(login: login, level: 10, activated_at: Time.current,
                          email: email, password: password)
ManualVerification.create!(account_id: account.id, unique_id: account.id)
