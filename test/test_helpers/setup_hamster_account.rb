module SetupHamsterAccount
  def create_hamster_account
    account = Account.where(login: 'ohloh_slave').first
    account ||= create_new_account
    account.update_attribute(:level, 10) if account
  end

  private

  def create_new_account
    GithubVerification.any_instance.stubs(:generate_access_token)
    Account.create(login: 'ohloh_slave', name: 'hamster', password: 'password', password_confirmation: 'password',
                   email: 'slave@ohloh.net', email_confirmation: 'slave@ohloh.net', activated_at: Time.current.utc,
                   github_verification_attributes: { auth_id: Faker::Internet.password })
  end
end
